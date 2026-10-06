const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const crypto = require("crypto");

const client = new DynamoDBClient({});

exports.handler = async (event) => {

    let body;

    try {
        body = JSON.parse(event.body);
    } catch (error) {
        return {
            statusCode: 400,
            body: JSON.stringify({
                message: "JSON inválido"
            })
        };
    }

    if (!body.title || !body.content) {
        return {
            statusCode: 400,
            body: JSON.stringify({
                message: "Campos obrigatórios ausentes"
            })
        };
    }

    const item = {
        id: {
            S: crypto.randomUUID()
        },
        title: {
            S: body.title
        },
        content: {
            S: body.content
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