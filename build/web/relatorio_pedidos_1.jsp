<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Pedidos de Clientes</title>
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
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 25px;
        }
        
        /* [Manter o restante do CSS igual ao original] */
        /* ... */
    </style>
</head>
<body>
    <div class="container">
        <h1>Pedidos de Clientes</h1>
        
        <form method="get" action="">
            <div class="filtros">
                <div class="filtro-group">
                    <label for="rg_cliente">RG do Cliente:</label>
                    <input type="text" id="rg_cliente" name="rg_cliente" class="form-control" 
                           value="<%= request.getParameter("rg_cliente") != null ? request.getParameter("rg_cliente") : "" %>">
                </div>
                
                <div class="filtro-group">
                    <label for="nome_cliente">Nome do Cliente:</label>
                    <input type="text" id="nome_cliente" name="nome_cliente" class="form-control" 
                           value="<%= request.getParameter("nome_cliente") != null ? request.getParameter("nome_cliente") : "" %>">
                </div>
                
                <div class="filtro-group">
                    <label for="pedido_id">Número do Pedido:</label>
                    <input type="text" id="pedido_id" name="pedido_id" class="form-control" 
                           value="<%= request.getParameter("pedido_id") != null ? request.getParameter("pedido_id") : "" %>">
                </div>
                
                <button type="submit" class="btn">Filtrar</button>
            </div>
        </form>
        
        <%
            // Parâmetros de filtro
            String rgCliente = request.getParameter("rg_cliente");
            String nomeCliente = request.getParameter("nome_cliente");
            String pedidoId = request.getParameter("pedido_id");
            
            // Conexão com o banco de dados
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;
            
            try {
                // Configuração da conexão para MariaDB
                Class.forName("org.mariadb.jdbc.Driver");
                conn = DriverManager.getConnection(
                    "jdbc:mariadb://localhost:3306/Rosbea", 
                    "paulo", 
                    "6421");
                
                // Construção da query SQL
                String sql = "SELECT * FROM vw_clientes_pedidos WHERE 1=1";
                
                if (rgCliente != null && !rgCliente.isEmpty()) {
                    sql += " AND rg = '" + rgCliente + "'";
                }
                
                if (nomeCliente != null && !nomeCliente.isEmpty()) {
                    sql += " AND nome_do_cliente LIKE '%" + nomeCliente + "%'";
                }
                
                if (pedidoId != null && !pedidoId.isEmpty()) {
                    sql += " AND pedido_id = " + pedidoId;
                }
                
                sql += " ORDER BY data_pedido DESC, nome_do_cliente";
                
                stmt = conn.createStatement();
                rs = stmt.executeQuery(sql);
                
                // Variáveis para controle de agrupamento
                String currentPedidoId = "";
                String currentRg = "";
                double totalPedido = 0;
                
                while (rs.next()) {
                    String rg = rs.getString("rg");
                    String pedido_id = rs.getString("pedido_id");
                    
                    // Se mudou o pedido, exibe os detalhes do cliente e cabeçalho do pedido
                    if (!pedido_id.equals(currentPedidoId) || !rg.equals(currentRg)) {
                        // Fecha a tabela do pedido anterior se existir
                        if (!currentPedidoId.isEmpty()) {
                            out.println("<div class='total-pedido'>Total do Pedido: R$ " + String.format("%.2f", totalPedido) + "</div>");
                            out.println("</div>");
                            totalPedido = 0;
                        }
                        
                        // Exibe detalhes do cliente
                        out.println("<div class='detalhes-cliente'>");
                        out.println("<h2>" + rs.getString("nome_do_cliente") + "</h2>");
                        out.println("<p><strong>RG:</strong> " + rg + "</p>");
                        out.println("<p><strong>Telefone:</strong> " + rs.getString("tel_cel") + " / " + rs.getString("tel_fijo") + "</p>");
                        out.println("<p><strong>Endereço:</strong> " + rs.getString("endereco") + ", " + rs.getString("nr") + " - " + rs.getString("barrio") + "</p>");
                        out.println("<p><strong>Cidade:</strong> " + rs.getString("cidade") + " - CEP: " + rs.getString("cep") + "</p>");
                        out.println("<p><strong>E-mail:</strong> " + rs.getString("email") + "</p>");
                        out.println("</div>");
                        
                        // Exibe cabeçalho do pedido
                        out.println("<div class='pedido-info'>");
                        out.println("<h3>Pedido #" + pedido_id + " - " + rs.getString("data_pedido") + "</h3>");
                        out.println("<p><strong>Observações:</strong> " + (rs.getString("observacoes") != null ? rs.getString("observacoes") : "") + "</p>");
                        
                        // Inicia tabela de itens
                        out.println("<table>");
                        out.println("<thead>");
                        out.println("<tr>");
                        out.println("<th>Produto</th>");
                        out.println("<th>Marca</th>");
                        out.println("<th>Quantidade</th>");
                        out.println("<th>Preço Unitário</th>");
                        out.println("<th>Total</th>");
                        out.println("</tr>");
                        out.println("</thead>");
                        out.println("<tbody>");
                        
                        currentPedidoId = pedido_id;
                        currentRg = rg;
                    }
                    
                    // Exibe item do pedido
                    out.println("<tr>");
                    out.println("<td>" + rs.getString("produto_nome") + " (" + rs.getString("ml") + ")</td>");
                    out.println("<td>" + rs.getString("marca") + "</td>");
                    out.println("<td>" + rs.getString("quantidade") + "</td>");
                    out.println("<td>R$ " + String.format("%.2f", rs.getDouble("preco")) + "</td>");
                    double totalItem = rs.getDouble("quantidade") * rs.getDouble("preco");
                    out.println("<td>R$ " + String.format("%.2f", totalItem) + "</td>");
                    out.println("</tr>");
                    
                    totalPedido += totalItem;
                }
                
                // Fecha a última tabela se existirem resultados
                if (!currentPedidoId.isEmpty()) {
                    out.println("</tbody>");
                    out.println("<div class='total-pedido'>Total do Pedido: R$ " + String.format("%.2f", totalPedido) + "</div>");
                    out.println("</div>");
                } else if (rgCliente != null || nomeCliente != null || pedidoId != null) {
                    out.println("<p>Nenhum pedido encontrado com os filtros aplicados.</p>");
                }
                
            } catch (ClassNotFoundException e) {
                out.println("<p class='error'>Erro: Driver JDBC do MariaDB não encontrado.</p>");
                out.println("<p class='error'>Certifique-se de que o arquivo mariadb-java-client-*.jar está no classpath.</p>");
            } catch (SQLException e) {
                out.println("<p class='error'>Erro ao acessar o banco de dados: " + e.getMessage() + "</p>");
            } finally {
                // Fechar recursos
                try { if (rs != null) rs.close(); } catch (SQLException e) {}
                try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
                try { if (conn != null) conn.close(); } catch (SQLException e) {}
            }
        %>
        
        <div class="acoes">
            <button class="btn" onclick="window.print()">Imprimir</button>
            <button class="btn" onclick="window.close()">Fechar</button>
        </div>
    </div>
</body>
</html>