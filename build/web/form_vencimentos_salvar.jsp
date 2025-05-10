<%@page import="java.sql.*" %>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@page import="java.util.Date" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.text.NumberFormat" %>
<%@page import="java.util.Locale" %>
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
            width: 100%;
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
            background-color: #5a5a5a;
        }

        .btn-success {
            background-color: var(--success-color);
        }

        .btn-success:hover {
            background-color: #3d8b40;
        }

        .btn-add {
            margin-top: 10px;
            background-color: var(--dark-gray);
        }

        .btn-add:hover {
            background-color: #5a5a5a;
        }

        .btn-remove {
            background-color: var(--error-color);
            margin-top: 10px;
        }

        .btn-remove:hover {
            background-color: #d32f2f;
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
            String dataPedidoStr = request.getParameter("data_pedido");
            Date dataPedido = null;
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            NumberFormat nf = NumberFormat.getNumberInstance(new Locale("pt", "BR"));
            nf.setMinimumFractionDigits(2);
            nf.setMaximumFractionDigits(2);

            Connection conForm = null;
            PreparedStatement pstmtRelatorioForm = null;
            ResultSet rsRelatorioForm = null;
            Double totalItemPedidoForm = 0.0;

            try {
                Class.forName("org.mariadb.jdbc.Driver");
                conForm = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

                String sqlRelatorioForm = "SELECT SUM(total_item) as total_item FROM view_relatorio_pedidos WHERE pedido_id = ?";
                pstmtRelatorioForm = conForm.prepareStatement(sqlRelatorioForm);
                pstmtRelatorioForm.setString(1, nrPedido);
                rsRelatorioForm = pstmtRelatorioForm.executeQuery();

                if (rsRelatorioForm.next()) {
                    totalItemPedidoForm = rsRelatorioForm.getDouble("total_item");
                }

                if (dataPedidoStr != null && !dataPedidoStr.isEmpty()) {
                    dataPedido = sdf.parse(dataPedidoStr);
                }

            } catch (Exception e) {
                out.println("<div style='color: red; text-align: center; margin-top: 20px;'>Erro ao buscar dados do pedido: " + e.getMessage() + "</div>");
                e.printStackTrace();
            } finally {
                try { if (rsRelatorioForm != null) rsRelatorioForm.close(); } catch (SQLException e) {}
                try { if (pstmtRelatorioForm != null) pstmtRelatorioForm.close(); } catch (SQLException e) {}
                try { if (conForm != null) conForm.close(); } catch (SQLException e) {}
            }
        %>
        <form action="salvar_vencimento.jsp" method="post" id="formVencimentos">
            <div class="form-group">
                <label for="nr_pedido">Número do Pedido:</label>
                <input type="text" id="nr_pedido" name="nr_pedido" value="<%= nrPedido != null ? nrPedido : "" %>" class="form-control readonly" readonly>
                <input type="hidden" name="nr_pedido" value="<%= nrPedido != null ? nrPedido : "" %>">
            </div>
            <div class="form-group">
                <label for="data_pedidovcto">Data do Pedido:</label>
                <input type="text" id="data_pedidovcto" name="data_pedidovcto" value="<%= dataPedidoStr != null ? dataPedidoStr : "" %>" class="form-control readonly" readonly>
                <input type="hidden" name="data_pedidovcto" value="<%= dataPedidoStr != null ? dataPedidoStr : "" %>">
            </div>
            <div class="form-group">
                <label for="total_item">Total do Pedido:</label>
                <input type="text" id="total_item" name="total_item" value="<%= nf.format(totalItemPedidoForm) %>" class="form-control readonly" readonly>
            </div>
            <div class="form-group">
                <label for="prazo">Prazo (em dias):</label>
                <input type="number" id="prazo" name="prazo[]" class="form-control" min="0" oninput="calcularVencimento()">
            </div>
            <div class="form-group">
                <label for="data_pagto">Data de Pagamento:</label>
                <input type="text" id="data_pagto" class="form-control readonly" readonly>
            </div>
            <div id="novosVencimentos">
                <!-- Área para novos vencimentos -->
            </div>
            <button type="button" class="btn btn-add" onclick="adicionarNovoVencimento()">+ Adicionar Vencimento</button>
            <div class="form-actions">
                <button type="submit" class="btn">Imprimir Pedido</button>
                <button type="button" class="btn btn-success" onclick="salvarSemImprimir()">Salvar sem Imprimir</button>
                <button type="button" class="btn btn-secondary" onclick="fecharJanela()">Fechar</button>
            </div>
        </form>
    </div>

    <script>
        function calcularVencimento() {
            var prazo = document.getElementById('prazo').value;
            var dataPedidoStr = document.getElementById('data_pedidovcto').value;
            var resultadoPagto = document.getElementById('data_pagto');
            
            if(!prazo || isNaN(prazo) || !dataPedidoStr) {
                resultadoPagto.value = "";
                return;
            }
            
            // Converte a string da data do pedido para Date
            var parts = dataPedidoStr.split('-');
            var dataPedido = new Date(parts[0], parts[1]-1, parts[2]);
            
            // Soma o prazo à data do pedido
            dataPedido.setDate(dataPedido.getDate() + parseInt(prazo));
            
            // Formata a data de vencimento
            var dia = dataPedido.getDate().toString().padStart(2, '0');
            var mes = (dataPedido.getMonth() + 1).toString().padStart(2, '0');
            var ano = dataPedido.getFullYear();
            
            resultadoPagto.value = dia + "/" + mes + "/" + ano;
        }

        function adicionarNovoVencimento() {
            var container = document.getElementById('novosVencimentos');
            
            var novoGrupo = document.createElement('div');
            novoGrupo.style.marginTop = '15px';
            novoGrupo.style.paddingTop = '15px';
            novoGrupo.style.borderTop = '1px dashed #e0e0e0';
            
            novoGrupo.innerHTML = `
                <div class="form-group">
                    <label>Prazo (em dias):</label>
                    <input type="number" name="prazo[]" class="form-control" min="0" oninput="calcularVencimentoAdicional(this)">
                </div>
                <div class="form-group">
                    <label>Data de Vencimento Prevista:</label>
                    <input type="text" class="form-control readonly" readonly>
                </div>
                <button type="button" class="btn btn-remove" onclick="this.parentNode.remove()">
                    Remover este vencimento
                </button>
            `;
            
            container.appendChild(novoGrupo);
        }

        function calcularVencimentoAdicional(input) {
            var grupo = input.parentNode.parentNode;
            var prazo = input.value;
            var dataVencimentoInput = grupo.querySelector('input[type="text"].readonly');
            
            if(!prazo || isNaN(prazo)) {
                dataVencimentoInput.value = "";
                return;
            }
            
            var hoje = new Date();
            hoje.setDate(hoje.getDate() + parseInt(prazo));
            
            var dia = hoje.getDate().toString().padStart(2, '0');
            var mes = (hoje.getMonth()+1).toString().padStart(2, '0');
            var ano = hoje.getFullYear();
            
            dataVencimentoInput.value = dia + "/" + mes + "/" + ano;
        }

        function fecharJanela() {
            try {
                if(window.opener || window.history.length <= 1) {
                    window.close();
                } else {
                    window.history.back();
                }
            } catch (e) {
                window.history.back();
            }
        }

        function salvarSemImprimir() {
            // Cria um campo hidden para indicar que é para salvar sem imprimir
            var inputHidden = document.createElement('input');
            inputHidden.type = 'hidden';
            inputHidden.name = 'acao';
            inputHidden.value = 'salvar';
            
            // Adiciona ao formulário
            var form = document.getElementById('formVencimentos');
            form.appendChild(inputHidden);
            
            // Submete o formulário
            form.submit();
        }
    </script>
</body>
</html>