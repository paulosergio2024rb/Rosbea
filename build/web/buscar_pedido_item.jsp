<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
    <head>
        <title>Buscar Item(ns) do Pedido</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f5f7fa;
                margin: 0;
                padding: 0;
                color: #333;
            }
            .container {
                width: 90%;
                max-width: 800px;
                margin: 30px auto;
                padding: 30px;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            }
            h1 {
                color: #2c3e50;
                margin-top: 0;
                margin-bottom: 25px;
                font-size: 24px;
                font-weight: 500;
            }
            .form-group {
                margin-bottom: 20px;
            }
            label {
                display: block;
                margin-bottom: 8px;
                font-weight: 500;
                color: #2c3e50;
            }
            input[type="number"],
            select {
                padding: 10px 12px;
                border: 1px solid #ddd;
                border-radius: 6px;
                box-sizing: border-box;
                width: 100%;
                font-size: 14px;
                transition: border-color 0.3s;
            }
            input[type="number"]:focus,
            select:focus {
                outline: none;
                border-color: #4a6fa5;
                box-shadow: 0 0 0 2px rgba(74, 111, 165, 0.2);
            }
            button {
                padding: 12px 20px;
                background-color: #4a6fa5;
                color: white;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                font-size: 14px;
                font-weight: 500;
                width: 100%;
                transition: background-color 0.3s;
            }
            button:hover {
                background-color: #166088;
            }
            .error {
                color: #e74c3c;
                margin-top: 15px;
                padding: 10px;
                background-color: #fdecea;
                border-radius: 4px;
                border-left: 4px solid #e74c3c;
            }
            .success {
                color: #27ae60;
                margin-top: 15px;
                padding: 10px;
                background-color: #e8f5e9;
                border-radius: 4px;
                border-left: 4px solid #27ae60;
            }
            .results-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 25px;
                font-size: 14px;
            }
            .results-table th,
            .results-table td {
                border: 1px solid #e0e0e0;
                padding: 12px;
                text-align: left;
            }
            .results-table th {
                background-color: #f8f9fa;
                font-weight: 500;
                color: #2c3e50;
            }
            .results-table tr:nth-child(even) {
                background-color: #f9f9f9;
            }
            .results-table tr:hover {
                background-color: #f1f5f9;
            }
        </style>
        <script>
            function submitForm() {
                const searchType = document.getElementById("search_type").value;
                const searchValue = document.getElementById("search_value").value;
                window.location.href = "editar_pedido_item.jsp?" + searchType + "=" + searchValue;
            }
        </script>
    </head>
    <a href="gerenciar_pedidos.html"></i> Voltar</a>
<body>
    <div class="container">
        <h1>Buscar Item(ns) do Pedido para Edição</h1>

        <div class="form-group">
            <label for="search_type">Buscar por:</label>
            <select id="search_type" class="form-control">
                <option value="item_id">ID do Item do Pedido</option>
                <option value="pedido_id">ID do Pedido (na tabela pedido_item)</option>
                <option value="pedido_principal_id">ID do Pedido Principal</option>
            </select>
        </div>

        <div class="form-group">
            <label for="search_value">Valor da Busca:</label>
            <input type="number" id="search_value" class="form-control" required>
        </div>

        <button onclick="submitForm()">Buscar</button>

        <% if (request.getParameter("success") != null) { %>
        <div class="success">Item(ns) do pedido atualizado(s) com sucesso!</div>
        <% } %>
        <% if (request.getParameter("error") != null) {%>
        <div class="error">Erro: <%= request.getParameter("error")%></div>
        <% }%>
    </div>
</body>
</html>