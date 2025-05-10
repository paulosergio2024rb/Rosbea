<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Detalhes do Pedido e Inserir Pagamento</title>
</head>
<body>
    <h1>Detalhes do Pedido</h1>

    <%
    String nrPedidoBusca = request.getParameter("nr_pedido");

    if (nrPedidoBusca != null && !nrPedidoBusca.isEmpty()) {
        String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea"; // Substitua pela sua URL JDBC
        String dbUser = "paulo";
        String dbPassword = "6421";
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("org.mariadb.jdbc.Driver");
            connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

            String sql = "SELECT * FROM vw_detalhes_impressao_pedido WHERE pedido_id = ?"; // Assumindo que pedido_id corresponde ao nr_pedido
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setString(1, nrPedidoBusca);
            resultSet = preparedStatement.executeQuery();

            if (resultSet.next()) {
                %>
                <table>
                    <tr><th>Cliente RG</th><td><%= resultSet.getString("cliente_rg") %></td></tr>
                    <tr><th>Nome do Cliente</th><td><%= resultSet.getString("nome_do_cliente") %></td></tr>
                    <tr><th>Responsável</th><td><%= resultSet.getString("responsavel") %></td></tr>
                    <tr><th>Direção</th><td><%= resultSet.getString("direcao") %></td></tr>
                    <tr><th>Cliente Nr</th><td><%= resultSet.getString("cliente_nr") %></td></tr>
                    <tr><th>Cliente Com</th><td><%= resultSet.getString("cliente_com") %></td></tr>
                    <tr><th>Cliente Bairro</th><td><%= resultSet.getString("cliente_barrio") %></td></tr>
                    <tr><th>Cliente Telefone</th><td><%= resultSet.getString("cliente_telefone") %></td></tr>
                    <tr><th>Cliente Cidade</th><td><%= resultSet.getString("cliente_cidade") %></td></tr>
                    <tr><th>Cliente CEP</th><td><%= resultSet.getString("cliente_cep") %></td></tr>
                    <tr><th>Pedido ID</th><td><%= resultSet.getInt("pedido_id") %></td></tr>
                    <tr><th>Data Pedido</th><td><%= resultSet.getDate("data_pedido") %></td></tr>
                    <tr><th>Mês Atual</th><td><%= resultSet.getString("mes_atual") %></td></tr>
                    <tr><th>Item ID</th><td><%= resultSet.getInt("item_id") %></td></tr>
                    <tr><th>Quantidade</th><td><%= resultSet.getInt("quantidade") %></td></tr>
                    <tr><th>Preço Unitário Item</th><td><%= resultSet.getDouble("preco_unitario_item") %></td></tr>
                    <tr><th>Produto Código</th><td><%= resultSet.getString("produto_codigo") %></td></tr>
                    <tr><th>Produto Nome</th><td><%= resultSet.getString("produto_nome") %></td></tr>
                    <tr><th>Produto Marca</th><td><%= resultSet.getString("produto_marca") %></td></tr>
                    <tr><th>Produto Preço Venda</th><td><%= resultSet.getDouble("produto_preco_venda") %></td></tr>
                    <tr><th>Código Barbearia</th><td><%= resultSet.getString("codigo_barbearia") %></td></tr>
                </table>

                <h2>Inserir Pagamento</h2>
                <form action="processar_pagamento_pedido.jsp" method="post">
                    <input type="hidden" name="nr_pedido" value="<%= nrPedidoBusca %>">
                    <div>
                        <label for="valor_pago">Valor Pago:</label>
                        <input type="number" id="valor_pago" name="valor_pago" step="0.01" required>
                    </div>
                    <br>
                    <button type="submit">Salvar Pagamento</button>
                </form>

                <%
            } else {
                out.println("<p>Pedido não encontrado com o número: " + nrPedidoBusca + "</p>");
            }

        } catch (ClassNotFoundException e) {
            out.println("<p>Erro: Driver do MariaDB não encontrado.</p>");
            e.printStackTrace();
        } catch (SQLException e) {
            out.println("<p>Erro de SQL: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            try {
                if (resultSet != null) resultSet.close();
                if (preparedStatement != null) preparedStatement.close();
                if (connection != null) connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        out.println("<p>Por favor, insira o número do pedido para buscar.</p>");
    }
    %>
    <br>
    <a href="buscar_pedido.jsp">Voltar para a Busca</a>
</body>
</html>