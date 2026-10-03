const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const crypto = require("crypto");

const client = new DynamoDBClient({});

exports.handler = async (event) => {
    const item = {
        id: {
            S: crypto.randomUUID()
        },
        title: {
            S: event.title
        },
        content: {
            S: event.content
        }
    };
    
    const command = new PutItemCommand({
        TableName: process.env.TABLE_NAME,
        Item: item
    });

    await client.send(command);

    return {
        statusCode: 200,
        body: JSON.stringify({
            message: "Post criado com sucesso"
        })
    };
};