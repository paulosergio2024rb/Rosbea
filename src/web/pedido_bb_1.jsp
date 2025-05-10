<%@page import="java.sql.*" %>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Novo Pedido - Barbearia</title>
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
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            background-color: var(--primary-color);
            color: white;
            padding: 20px 0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        header h1 {
            text-align: center;
            font-weight: 500;
        }
        
        .card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 25px;
            margin-bottom: 30px;
        }
        
        .card h2 {
            color: var(--secondary-color);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--medium-gray);
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
        
        select.form-control {
            height: auto;
            padding: 10px;
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
            transition: background-color 0.3s;
            text-decoration: none;
        }
        
        .btn:hover {
            background-color: var(--secondary-color);
        }
        
        .btn-block {
            display: block;
            width: 100%;
        }
        
        .table-responsive {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 25px 0;
            font-size: 0.9em;
            min-width: 600px;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        
        table thead tr {
            background-color: var(--primary-color);
            color: white;
            text-align: left;
        }
        
        table th, table td {
            padding: 12px 15px;
            border: 1px solid var(--medium-gray);
        }
        
        table tbody tr {
            border-bottom: 1px solid var(--medium-gray);
        }
        
        table tbody tr:nth-of-type(even) {
            background-color: var(--light-gray);
        }
        
        table tbody tr:last-of-type {
            border-bottom: 2px solid var(--primary-color);
        }
        
        table tbody tr:hover {
            background-color: rgba(79, 195, 247, 0.1);
        }
        
        .total {
            font-weight: bold;
            font-size: 1.2em;
            margin: 15px 0;
            padding: 10px;
            background-color: var(--light-gray);
            border-radius: 4px;
            text-align: right;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .alert-error {
            background-color: #f2dede;
            color: #a94442;
            border: 1px solid #ebccd1;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }
        }
    </style>
    <script>
        function atualizarPreco(e) {
            const row = e.target.closest('tr');
            const selected = e.target.selectedOptions[0];
            const preco = selected.getAttribute("data-preco");
            row.querySelector(".preco").value = preco;
            calcularSubtotal(row);
        }

        function calcularSubtotal(row) {
            const qtd = parseFloat(row.querySelector(".quantidade").value || 0);
            const preco = parseFloat(row.querySelector(".preco").value || 0);
            const subtotal = qtd * preco;
            row.querySelector(".subtotal").value = subtotal.toFixed(2);
            calcularTotal();
        }

        function calcularTotal() {
            const subtotais = document.querySelectorAll(".subtotal");
            let total = 0;
            subtotais.forEach(input => total += parseFloat(input.value || 0));
            document.getElementById("totalPedido").innerText = total.toFixed(2);
        }

        function adicionarItem() {
            const tabela = document.getElementById("itens");
            const novaLinha = tabela.rows[1].cloneNode(true);
            novaLinha.querySelector(".quantidade").value = "";
            novaLinha.querySelector(".preco").value = "";
            novaLinha.querySelector(".subtotal").value = "";
            tabela.appendChild(novaLinha);
        }
    </script>
</head>
<body>
    <header>
        <div class="container">
            <h1>Sistema de Pedidos - Barbearia</h1>
        </div>
    </header>
    
    <div class="container">
        <div class="card">
            <h2>Novo Pedido - Barbearia</h2>
            
            <form action="carregar_produtos.jsp" method="post">
                <div class="form-group">
                    <label>Cliente:</label>
                    <select name="cliente_rg" class="form-control" required>
                        <%
                            Connection con = null;
                            try {
                                Class.forName("org.mariadb.jdbc.Driver");
                                con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");
                                PreparedStatement stmt = con.prepareStatement("SELECT rg, nome_do_cliente FROM cadastro_de_clientes ORDER BY nome_do_cliente");
                                ResultSet rs = stmt.executeQuery();
                                while (rs.next()) {
                        %>
                        <option value="<%= rs.getString("rg") %>"><%= rs.getString("nome_do_cliente") %></option>
                        <%
                                }
                            } catch (Exception e) {
                                out.print("<div class='alert alert-error'>Erro ao carregar clientes: " + e.getMessage() + "</div>");
                            } finally {
                                if (con != null) con.close();
                            }
                        %>
                    </select>
                </div>

                <div class="table-responsive">
                    <table id="itens">
                        <thead>
                            <tr>
                                <th>Produto (Código Barbearia)</th>
                                <th>Quantidade</th>
                                <th>Preço</th>
                                <th>Subtotal</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>
                                    <select name="produto_id[]" class="form-control" onchange="atualizarPreco(event)" required>
                                        <option value="">-- Selecione --</option>
                                        <%
                                            try {
                                                Class.forName("org.mariadb.jdbc.Driver");
                                                con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");
                                                PreparedStatement ps = con.prepareStatement("SELECT codigo, codigo_barbearia, preco FROM produto ORDER BY codigo_barbearia");
                                                ResultSet produtos = ps.executeQuery();
                                                while (produtos.next()) {
                                        %>
                                        <option value="<%= produtos.getInt("codigo") %>" data-preco="<%= produtos.getDouble("preco") %>">
                                            <%= produtos.getString("codigo_barbearia") %>
                                        </option>
                                        <%
                                                }
                                            } catch (Exception ex) {
                                                out.print("<div class='alert alert-error'>Erro ao carregar produtos: " + ex.getMessage() + "</div>");
                                            } finally {
                                                if (con != null) con.close();
                                            }
                                        %>
                                    </select>
                                </td>
                                <td><input type="number" name="quantidade[]" class="form-control quantidade" oninput="calcularSubtotal(this.closest('tr'))" min="1" required></td>
                                <td><input type="text" class="form-control preco" readonly></td>
                                <td><input type="text" name="subtotal[]" class="form-control subtotal" readonly></td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <button type="button" class="btn" onclick="adicionarItem()">+ Adicionar Item</button>

                <div class="total">Total do Pedido: R$ <span id="totalPedido">0.00</span></div>

                <input type="submit" value="Salvar Pedido" class="btn btn-block">
            </form>
        </div>
    </div>
</body>
</html>