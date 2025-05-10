<%@page import="java.sql.*"%>
<%@page contentType="text/html;charset=UTF-8"%>
<%
    String pedidoId = request.getParameter("pedido_id");
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Relatório do Pedido #<%= pedidoId%> - Rosbea</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            :root {
                --primary-color: #3498db;
                --secondary-color: #2ecc71;
                --dark-color: #2c3e50;
                --light-color: #f5f8fa;
                --danger-color: #e74c3c;
                --border-radius: 8px;
                --box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                --transition: all 0.3s ease;
            }
            
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: var(--light-color);
                margin: 0;
                padding: 20px;
                color: #333;
                line-height: 1.6;
            }
            
            .container {
                max-width: 1000px;
                margin: 20px auto;
                background: #fff;
                padding: 30px;
                border-radius: var(--border-radius);
                box-shadow: var(--box-shadow);
                position: relative;
            }
            
            .header {
                text-align: center;
                margin-bottom: 30px;
                padding-bottom: 20px;
                border-bottom: 1px solid #eee;
            }
            
            h2 {
                color: var(--dark-color);
                margin: 0;
                font-size: 28px;
            }
            
            .pedido-id {
                color: var(--primary-color);
                font-weight: bold;
            }
            
            .client-info {
                background-color: #f8f9fa;
                padding: 20px;
                border-radius: var(--border-radius);
                margin-bottom: 30px;
            }
            
            .info-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                gap: 15px;
            }
            
            .info-item {
                margin-bottom: 5px;
            }
            
            .info-label {
                font-weight: 600;
                color: var(--dark-color);
                display: inline-block;
                min-width: 120px;
            }
            
            table {
                width: 100%;
                border-collapse: collapse;
                margin: 25px 0;
                font-size: 0.9em;
                box-shadow: var(--box-shadow);
                border-radius: var(--border-radius);
                overflow: hidden;
            }
            
            thead tr {
                background-color: var(--primary-color);
                color: white;
                text-align: left;
            }
            
            th, td {
                padding: 12px 15px;
            }
            
            tbody tr {
                border-bottom: 1px solid #dddddd;
            }
            
            tbody tr:nth-of-type(even) {
                background-color: #f3f3f3;
            }
            
            tbody tr:last-of-type {
                border-bottom: 2px solid var(--primary-color);
            }
            
            .total-container {
                display: flex;
                justify-content: flex-end;
                margin-top: 20px;
            }
            
            .total-box {
                background-color: var(--dark-color);
                color: white;
                padding: 15px 25px;
                border-radius: var(--border-radius);
                font-size: 1.2em;
                font-weight: bold;
                box-shadow: var(--box-shadow);
            }
            
            .actions {
                display: flex;
                justify-content: space-between;
                margin-top: 30px;
                flex-wrap: wrap;
                gap: 15px;
            }
            
            .btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 10px 20px;
                border-radius: var(--border-radius);
                text-decoration: none;
                font-weight: 500;
                transition: var(--transition);
                border: none;
                cursor: pointer;
                font-size: 1em;
            }
            
            .btn-primary {
                background-color: var(--primary-color);
                color: white;
            }
            
            .btn-primary:hover {
                background-color: #2980b9;
            }
            
            .btn-success {
                background-color: var(--secondary-color);
                color: white;
            }
            
            .btn-success:hover {
                background-color: #27ae60;
            }
            
            .btn i {
                margin-right: 8px;
            }
            
            .error-message {
                color: var(--danger-color);
                background-color: #fde8e8;
                padding: 15px;
                border-radius: var(--border-radius);
                margin: 20px 0;
                border-left: 4px solid var(--danger-color);
            }
            
            @media print {
                .no-print {
                    display: none;
                }
                
                body {
                    padding: 0;
                    background: none;
                }
                
                .container {
                    box-shadow: none;
                    padding: 10px;
                }
            }
            
            @media (max-width: 768px) {
                .info-grid {
                    grid-template-columns: 1fr;
                }
                
                table {
                    font-size: 0.8em;
                }
                
                th, td {
                    padding: 8px 10px;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h2>Relatório do Pedido <span class="pedido-id">#<%= pedidoId%></span></h2>
            </div>

            <div class="no-print">
                <form action="imprimirPedidoDireto.jsp" method="get" style="margin-bottom: 20px;">
                    <input type="hidden" name="pedido_id" value="<%= pedidoId%>">
                    <button type="submit" class="btn btn-success">
                        <i class="fas fa-print"></i> Imprimir Pedido Direto
                    </button>
                </form>
            </div>

            <%
                Connection con = null;
                double total = 0.0;
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

                    PreparedStatement psPedido = con.prepareStatement(
                            "SELECT p.data_pedido, p.data_atende, c.nome_do_cliente, c.telefone, c.endereco "
                            + "FROM pedido p JOIN cadastro_de_clientes c ON p.cliente_id = c.rg WHERE p.id = ?");
                    psPedido.setInt(1, Integer.parseInt(pedidoId));
                    ResultSet pedidoRs = psPedido.executeQuery();

                    if (pedidoRs.next()) {
                        java.sql.Date dataPedido = pedidoRs.getDate("data_pedido");
                        java.sql.Date dataAtende = pedidoRs.getDate("data_atende");
            %>
            <div class="client-info">
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Cliente:</span>
                        <span><%= pedidoRs.getString("nome_do_cliente")%></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Telefone:</span>
                        <span><%= pedidoRs.getString("telefone") != null ? pedidoRs.getString("telefone") : "N/A"%></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Endereço:</span>
                        <span><%= pedidoRs.getString("endereco") != null ? pedidoRs.getString("endereco") : "N/A"%></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Data do Pedido:</span>
                        <span><%= (dataPedido != null ? dataPedido.toString() : "N/A")%></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Data de Atendimento:</span>
                        <span><%= (dataAtende != null ? dataAtende.toString() : "N/A")%></span>
                    </div>
                </div>
            </div>
            <%
                }

                PreparedStatement psItens = con.prepareStatement(
                        "SELECT pr.nome, pi.quantidade, pi.preco FROM pedido_item pi "
                        + "JOIN produto pr ON pi.produto_id = pr.codigo WHERE pi.pedido_id = ?");
                psItens.setInt(1, Integer.parseInt(pedidoId));
                ResultSet itensRs = psItens.executeQuery();
            %>
            <table>
                <thead>
                    <tr>
                        <th>Produto</th>
                        <th>Quantidade</th>
                        <th>Preço Unitário</th>
                        <th>Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        while (itensRs.next()) {
                            String nome = itensRs.getString("nome");
                            int qtd = itensRs.getInt("quantidade");
                            double preco = itensRs.getDouble("preco");
                            double subtotal = qtd * preco;
                            total += subtotal;
                    %>
                    <tr>
                        <td><%= nome%></td>
                        <td><%= qtd%></td>
                        <td>R$ <%= String.format("%.2f", preco)%></td>
                        <td>R$ <%= String.format("%.2f", subtotal)%></td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>

            <div class="total-container">
                <div class="total-box">
                    Total do Pedido: R$ <%= String.format("%.2f", total)%>
                </div>
            </div>

            <%
                } catch (Exception e) {
            %>
            <div class="error-message">
                <i class="fas fa-exclamation-circle"></i> Erro ao carregar relatório: <%= e.getMessage() %>
            </div>
            <%
                } finally {
                    if (con != null) {
                        con.close();
                    }
                }
            %>

            <div class="actions no-print">
                <a href="gerenciar_pedidos.html" class="btn btn-primary">
                    <i class="fas fa-arrow-left"></i> Voltar aos Pedidos
                </a>
            </div>
        </div>
    </body>
</html>