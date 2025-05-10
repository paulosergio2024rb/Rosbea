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
            padding: 20px;
            margin: 0;
        }

        .container {
            max-width: 600px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 25px;
        }

        h1 {
            color: var(--secondary-color);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--medium-gray);
            text-align: center;
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

        .form-control.readonly {
            background-color: var(--light-gray);
            cursor: not-allowed;
        }

        .btn {
            display: inline-block;
            background-color: var(--primary-color);
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
            background-color: var(--secondary-color);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .btn-secondary {
            background-color: var(--dark-gray);
        }

        .btn-secondary:hover {
            background-color: #616161;
        }

        .form-actions {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }

        .form-actions .btn {
            flex: 1;
        }

        @media (max-width: 768px) {
            .container {
                padding: 15px;
            }

            .form-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Cadastro de Vencimentos</h1>
        <%
            String nrPedido = request.getParameter("id_pedido");
            String dataPedido = request.getParameter("data_pedido");
        %>
        <form action="salvar_vencimento.jsp" method="post">
            <div class="form-group">
                <label for="nr_pedido">Número do Pedido:</label>
                <input type="text" id="nr_pedido" name="nr_pedido" value="<%= nrPedido != null ? nrPedido : "" %>" class="form-control readonly" readonly>
                <input type="hidden" name="nr_pedido" value="<%= nrPedido != null ? nrPedido : "" %>">
            </div>
            <div class="form-group">
                <label for="data_pedidovcto">Data do Pedido:</label>
                <input type="text" id="data_pedidovcto" name="data_pedidovcto" value="<%= dataPedido != null ? dataPedido : "" %>" class="form-control readonly" readonly>
                <input type="hidden" name="data_pedidovcto" value="<%= dataPedido != null ? dataPedido : "" %>">
            </div>
            <div class="form-group">
                <label for="valor_ped">Valor do Vencimento:</label>
                <input type="number" id="valor_ped" name="valor_ped[]" step="0.01" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="prazo">Prazo (em dias):</label>
                <input type="number" id="prazo" name="prazo[]" class="form-control">
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

            // Container para o novo grupo de vencimento
            const vencimentoGroup = document.createElement('div');
            vencimentoGroup.style.marginTop = '15px';
            vencimentoGroup.style.paddingTop = '15px';
            vencimentoGroup.style.borderTop = '1px dashed var(--medium-gray)';

            // Valor do Vencimento
            const valorPedDiv = document.createElement('div');
            valorPedDiv.className = 'form-group';
            const valorPedLabel = document.createElement('label');
            valorPedLabel.setAttribute('for', 'valor_ped[]');
            valorPedLabel.innerText = 'Valor do Vencimento:';
            const valorPedInput = document.createElement('input');
            valorPedInput.type = 'number';
            valorPedInput.name = 'valor_ped[]';
            valorPedInput.step = '0.01';
            valorPedInput.className = 'form-control';
            valorPedInput.required = true;
            valorPedDiv.appendChild(valorPedLabel);
            valorPedDiv.appendChild(valorPedInput);

            // Prazo
            const prazoDiv = document.createElement('div');
            prazoDiv.className = 'form-group';
            const prazoLabel = document.createElement('label');
            prazoLabel.setAttribute('for', 'prazo[]');
            prazoLabel.innerText = 'Prazo (em dias):';
            const prazoInput = document.createElement('input');
            prazoInput.type = 'number';
            prazoInput.name = 'prazo[]';
            prazoInput.className = 'form-control';

            // Botão de remover
            const removeButton = document.createElement('button');
            removeButton.type = 'button';
            removeButton.className = 'btn btn-secondary';
            removeButton.style.marginTop = '10px';
            removeButton.innerText = 'Remover este vencimento';
            removeButton.onclick = function() {
                novosVencimentosDiv.removeChild(vencimentoGroup);
            };

            // Montando a estrutura
            prazoDiv.appendChild(prazoLabel);
            prazoDiv.appendChild(prazoInput);

            vencimentoGroup.appendChild(valorPedDiv);
            vencimentoGroup.appendChild(prazoDiv);
            vencimentoGroup.appendChild(removeButton);

            novosVencimentosDiv.appendChild(vencimentoGroup);
        }
    </script>
</body>
</html>