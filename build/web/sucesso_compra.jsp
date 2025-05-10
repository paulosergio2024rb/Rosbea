<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String compraId = request.getParameter("id");
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Compra Registrada com Sucesso</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            text-align: center;
        }
        .success-container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            border: 1px solid #4CAF50;
            border-radius: 5px;
            background-color: #f8fff8;
        }
        .success-message {
            color: #4CAF50;
            font-size: 24px;
            margin-bottom: 20px;
        }
        .compra-id {
            font-size: 20px;
            margin: 15px 0;
            padding: 10px;
            background-color: #e8f5e9;
            border-radius: 4px;
        }
        .btn {
            display: inline-block;
            background-color: #4CAF50;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            margin: 10px 5px;
        }
        .btn:hover {
            background-color: #45a049;
        }
        .btn-print {
            background-color: #2196F3;
        }
        .btn-print:hover {
            background-color: #0b7dda;
        }
    </style>
</head>
<body>
    <div class="success-container">
        <div class="success-message">✓ Compra registrada com sucesso!</div>
        
        <div class="compra-id">
            Número do Pedido: <strong><%= compraId %></strong>
        </div>
        
        <div>
            <a href="compra_form.html" class="btn">Nova Compra</a>
            <a href="lista_compras.jsp" class="btn">Ver Todas as Compras</a>
            <a href="javascript:window.print()" class="btn btn-print">Imprimir</a>
        </div>
    </div>
</body>
</html>