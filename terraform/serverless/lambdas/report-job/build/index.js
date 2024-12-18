"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.handler = void 0;
var AWS = require("aws-sdk");
var pg_1 = require("pg");
var mongodb_1 = require("mongodb");
var fs = require("fs");
var util_1 = require("util");
var secretsManager = new AWS.SecretsManager();
var rdsProxyEndpoint = process.env.RDS_PROXY_ENDPOINT;
var rdsSecretArn = process.env.RDS_SECRET_ARN;
var documentDbSecretArn = process.env.DOCUMENTDB_SECRET_ARN;
var documentDBEndpoint = process.env.DOCUMENTDB_ENDPOINT;
var documentDBDatabaseName = process.env.DOCUMENTDB_DATABASE_NAME;
var rdsDatabaseName = process.env.RDS_DATABASE_NAME;
var bucketName = process.env.BUCKET_NAME;
var documentDbCertObjectKey = process.env.DOCUMENTDB_CERT_OBJECT_KEY;
var handler = function (event, _) { return __awaiter(void 0, void 0, void 0, function () {
    var rdsSecret, documentDbSecret, rdsClient, s3, params, Body, certFilePath, writeFileAsync, mongoConnectionString, documentDBClient, queryResult, db, collection, _i, _a, row, error_1;
    return __generator(this, function (_b) {
        switch (_b.label) {
            case 0:
                console.log(event);
                return [4 /*yield*/, getSecretJson(rdsSecretArn)];
            case 1:
                rdsSecret = _b.sent();
                return [4 /*yield*/, getSecretJson(documentDbSecretArn)];
            case 2:
                documentDbSecret = _b.sent();
                rdsClient = new pg_1.Client({
                    host: rdsProxyEndpoint,
                    user: rdsSecret.username,
                    password: rdsSecret.password,
                    database: rdsDatabaseName,
                    ssl: true,
                    port: 5432,
                });
                s3 = new AWS.S3();
                params = {
                    Bucket: bucketName,
                    Key: documentDbCertObjectKey
                };
                return [4 /*yield*/, s3.getObject(params).promise()];
            case 3:
                Body = (_b.sent()).Body;
                certFilePath = '/tmp/certificate.pem';
                writeFileAsync = (0, util_1.promisify)(fs.writeFile);
                return [4 /*yield*/, writeFileAsync(certFilePath, Body === null || Body === void 0 ? void 0 : Body.toString())];
            case 4:
                _b.sent();
                mongoConnectionString = "mongodb://".concat(documentDbSecret.username, ":").concat(documentDbSecret.password, "@").concat(documentDBEndpoint, ":27017");
                documentDBClient = new mongodb_1.MongoClient(mongoConnectionString, {
                    tls: true,
                    tlsCAFile: certFilePath,
                    retryWrites: false,
                });
                _b.label = 5;
            case 5:
                _b.trys.push([5, 14, 15, 17]);
                return [4 /*yield*/, rdsClient.connect()];
            case 6:
                _b.sent();
                return [4 /*yield*/, documentDBClient.connect()];
            case 7:
                _b.sent();
                return [4 /*yield*/, rdsClient.query("\n        SELECT\n            p.\"Id\" AS \"ProductId\",\n            p.\"Name\" AS \"ProductName\",\n            COUNT(o.\"ProductId\") AS \"TotalOrders\",\n          SUM(o.\"Quantity\") AS \"TotalOrdered\",\n          SUM(o.\"Quantity\" * p.\"Price\") AS \"TotalSold\"\n        FROM\n            public.\"Order\" o\n        JOIN\n            public.\"Product\" p ON o.\"ProductId\" = p.\"Id\"\n        GROUP BY\n            p.\"Id\", p.\"Name\";\n      ")];
            case 8:
                queryResult = _b.sent();
                db = documentDBClient.db(documentDBDatabaseName);
                collection = db.collection("reports");
                return [4 /*yield*/, collection.deleteMany({})];
            case 9:
                _b.sent();
                _i = 0, _a = queryResult.rows;
                _b.label = 10;
            case 10:
                if (!(_i < _a.length)) return [3 /*break*/, 13];
                row = _a[_i];
                return [4 /*yield*/, collection.insertOne({
                        productId: row.ProductId,
                        productName: row.ProductName,
                        totalOrders: row.TotalOrders,
                        totalOrdered: row.TotalOrdered,
                        totalSold: row.TotalSold,
                    })];
            case 11:
                _b.sent();
                _b.label = 12;
            case 12:
                _i++;
                return [3 /*break*/, 10];
            case 13: return [2 /*return*/, { statusCode: 200, body: "Data saved successfully." }];
            case 14:
                error_1 = _b.sent();
                console.error("Failed to update Order:", error_1);
                throw error_1;
            case 15: return [4 /*yield*/, rdsClient.end()];
            case 16:
                _b.sent();
                return [7 /*endfinally*/];
            case 17: return [2 /*return*/];
        }
    });
}); };
exports.handler = handler;
function getSecretJson(secretArn) {
    return __awaiter(this, void 0, void 0, function () {
        var data;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, secretsManager
                        .getSecretValue({ SecretId: secretArn })
                        .promise()];
                case 1:
                    data = _a.sent();
                    if ("SecretString" in data) {
                        return [2 /*return*/, JSON.parse(data.SecretString)];
                    }
                    throw new Error("Secret not found");
            }
        });
    });
}
