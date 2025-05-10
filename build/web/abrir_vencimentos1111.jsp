<%@page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Cadastro de Vencimentos</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4a6fa5;
            --secondary-color: #166088;
            --accent-color: #4fc3f7;
            --success-color: #4caf50;
            --error-color: #f44336;
            --light-gray: #f5f5f5;
            --medium-gray: #e0e0e0;
            --dark-gray: #757575;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Roboto', sans-serif;
            line-height: 1.6;
            color: #333;
            background-color: #f9f9f9;
            padding: 0;
            margin: 0;
        }

        .container {
            max-width: 600px;
            margin: 30px auto;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        h1 {
            color: var(--secondary-color);
            text-align: center;
            margin-bottom: 20px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: var(--secondary-color);
        }

        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid var(--medium-gray);
            border-radius: 4px;
            font-size: 16px;
            transition: border 0.3s;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--accent-color);
            box-shadow: 0 0 0 2px rgba(79, 195, 247, 0.2);
        }

        .btn {
            display: inline-block;
            background-color: var(--success-color);
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            text-align: center;
            transition: all 0.3s;
            text-decoration: none;
        }

        .btn:hover {
            background-color: #388e3c;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .btn-secondary {
            background-color: var(--primary-color);
        }

        .btn-secondary:hover {
            background-color: var(--secondary-color);
        }

        .readonly {
            background-color: var(--light-gray);
            cursor: not-allowed;
        }

        .form-actions {
            margin-top: 20px;
            text-align: right;
        }

        .form-actions .btn {
            margin-left: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Cadastro de Vencimentos</h1>

        <%
            String idPedido = request.getParameter("id_pedido");
            String dataPedido = request.getParameter("data_pedido");
        %>

        <form action="salvar_vencimento.jsp" method="post">
            <div class="form-group">
                <label for="id_pedido">ID do Pedido:</label>
                <input type="text" id="id_pedido" name="id_pedido" value="<%= idPedido != null ? idPedido : "" %>" class="form-control readonly" readonly>
            </div>

            <div class="form-group">
                <label for="data_pedido">Data do Pedido:</label>
                <input type="text" id="data_pedido" name="data_pedido" value="<%= dataPedido != null ? dataPedido : "" %>" class="form-control readonly" readonly>
            </div>

            <div class="form-group">
                <label for="data_vencimento">Data de Vencimento:</label>
                <input type="date" id="data_vencimento" name="data_vencimento[]" class="form-control" required>
            </div>

            <div class="form-group">
                <label for="valor">Valor:</label>
                <input type="number" id="valor" name="valor[]" step="0.01" class="form-control" required>
            </div>

            <div id="novosVencimentos">
                </div>

            <button type="button" class="btn btn-secondary" onclick="adicionarNovoVencimento()">+ Adicionar Vencimento</button>

            <div class="form-actions">
                <button type="submit" class="btn">Salvar Vencimentos</button>
                <button type="button" class="btn btn-secondary" onclick="window.close()">Fechar</button>
            </div>
        </form>
    </div>

    <script>
        function adicionarNovoVencimento() {
            const novosVencimentosDiv = document.getElementById('novosVencimentos');

            const dataVencimentoDiv = document.createElement('div');
            dataVencimentoDiv.className = 'form-group';
            const dataVencimentoLabel = document.createElement('label');
            dataVencimentoLabel.setAttribute('for', 'data_vencimento[]');
            dataVencimentoLabel.innerText = 'Data de Vencimento:';
            const dataVencimentoInput = document.createElement('input');
            dataVencimentoInput.type = 'date';
            dataVencimentoInput.name = 'data_vencimento[]';
            dataVencimentoInput.className = 'form-control';
            dataVencimentoInput.required = true;
            dataVencimentoDiv.appendChild(dataVencimentoLabel);
            dataVencimentoDiv.appendChild(dataVencimentoInput);
            novosVencimentosDiv.appendChild(dataVencimentoDiv);

            const valorDiv = document.createElement('div');
            valorDiv.className = 'form-group';
            const valorLabel = document.createElement('label');
            valorLabel.setAttribute('for', 'valor[]');
            valorLabel.innerText = 'Valor:';
            const valorInput = document.createElement('input');
            valorInput.type = 'number';
            valorInput.name = 'valor[]';
            valorInput.step = '0.01';
            valorInput.className = 'form-control';
            valorInput.required = true;
            valorDiv.appendChild(valorLabel);
            valorDiv.appendChild(valorInput);
            novosVencimentosDiv.appendChild(valorDiv);
        }
    </script>
</body>
</html>