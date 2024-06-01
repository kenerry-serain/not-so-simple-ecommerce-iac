import * as AWS from "aws-sdk";
import { Client } from "pg";
import { Context } from "aws-lambda";
import { MongoClient } from "mongodb";
import * as fs from 'fs';
import { promisify } from 'util';

const secretsManager = new AWS.SecretsManager();
const rdsProxyEndpoint = process.env.RDS_PROXY_ENDPOINT as string;
const rdsSecretArn = process.env.RDS_SECRET_ARN as string;
const documentDbSecretArn = process.env.DOCUMENTDB_SECRET_ARN as string;
const documentDBEndpoint = process.env.DOCUMENTDB_ENDPOINT as string;
const documentDBDatabaseName = process.env.DOCUMENTDB_DATABASE_NAME as string;
const rdsDatabaseName = process.env.RDS_DATABASE_NAME as string;
const bucketName= process.env.BUCKET_NAME as string;
const documentDbCertObjectKey= process.env.DOCUMENTDB_CERT_OBJECT_KEY as string;

export const handler = async (event: any, _: Context) => {
  console.log(event);

  /* Recuperando Secret do Banco de Dados RDS */
  const rdsSecret = await getSecretJson(rdsSecretArn);
  const documentDbSecret = await getSecretJson(documentDbSecretArn);

  /* Conectando no Banco de Dados RDS */
  const rdsClient = new Client({
    host: rdsProxyEndpoint,
    user: rdsSecret.username,
    password: rdsSecret.password,
    database: rdsDatabaseName,
    ssl: true,
    port: 5432,
  });

  const s3 = new AWS.S3();

  // Download the certificate file from S3
  const params = {
      Bucket: bucketName,
      Key: documentDbCertObjectKey
  };

  const { Body } = await s3.getObject(params).promise();
  const certFilePath = '/tmp/certificate.pem';
  const writeFileAsync = promisify(fs.writeFile);
  await writeFileAsync(certFilePath, Body?.toString() as string);

  /* Conectando no Banco de Dados DocumentDB */
  const mongoConnectionString = `mongodb://${documentDbSecret.username}:${documentDbSecret.password}@${documentDBEndpoint}:27017`;
  const documentDBClient = new MongoClient(mongoConnectionString, {
    tls: true,
    tlsCAFile: certFilePath,
    retryWrites: false,
  });

  try {
    await rdsClient.connect();
    await documentDBClient.connect();

    /* Query RDS Database for necessary data */
    const queryResult = await rdsClient.query(
      `
        SELECT
            p."Id" AS "ProductId",
            p."Name" AS "ProductName",
            COUNT(o."ProductId") AS "TotalOrders",
          SUM(o."Quantity") AS "TotalOrdered",
          SUM(o."Quantity" * p."Price") AS "TotalSold"
        FROM
            public."Order" o
        JOIN
            public."Product" p ON o."ProductId" = p."Id"
        GROUP BY
            p."Id", p."Name";
      `
    );
    
    /* Save data to DocumentDB */
    const db = documentDBClient.db(documentDBDatabaseName);
    const collection = db.collection("reports");
    await collection.deleteMany({});

    // Iterate through query results and insert each record into DocumentDB
    for (const row of queryResult.rows) {
        await collection.insertOne({
            productId: row.ProductId,
            productName: row.ProductName,
            totalOrders: row.TotalOrders,
            totalOrdered: row.TotalOrdered,
            totalSold: row.TotalSold,
        });
    }

    return { statusCode: 200, body: "Data saved successfully." };
  } catch (error) {
    console.error("Failed to update Order:", error);
    throw error;
  } finally {
    await rdsClient.end();
  }
};

async function getSecretJson(secretArn: string): Promise<any> {
  const data = await secretsManager
    .getSecretValue({ SecretId: secretArn })
    .promise();
  if ("SecretString" in data) {
    return JSON.parse(data.SecretString as string);
  }
  throw new Error("Secret not found");
}

