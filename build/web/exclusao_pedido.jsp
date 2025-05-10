<%@page import="java.sql.*"%>
<%@page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Exclusão de Pedido</title>
    <style>
        body {
            font-family: sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }
        .container {
            background-color: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        h2 {
            color: #5cb85c;
            margin-bottom: 20px;
        }
        p {
            margin-bottom: 15px;
        }
        .success {
            color: #5cb85c;
            font-weight: bold;
        }
        .error {
            color: #d9534f;
            font-weight: bold;
        }
        a {
            color: #007bff;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <%
            String pedidoIdExcluir = request.getParameter("pedido_id");
            if (pedidoIdExcluir != null && !pedidoIdExcluir.isEmpty()) {
                Connection con = null;
                PreparedStatement psExcluirItens = null;
                PreparedStatement psExcluirVencimentos = null;
                PreparedStatement psExcluirPedido = null;

                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
                    con.setAutoCommit(false);

                    int pedidoIdInt;
                    try {
                        pedidoIdInt = Integer.parseInt(pedidoIdExcluir);
                    } catch (NumberFormatException e) {
                        out.println("<p class='error'>Erro: ID do pedido para exclusão inválido. Por favor, volte e tente novamente com um número inteiro.</p>");
                        return;
                    }

                    String sqlExcluirItens = "DELETE FROM pedido_item WHERE pedido_id = ?";
                    psExcluirItens = con.prepareStatement(sqlExcluirItens);
                    psExcluirItens.setInt(1, pedidoIdInt);
                    int itensExcluidos = psExcluirItens.executeUpdate();
                    out.println("<p>Itens excluídos: " + itensExcluidos + "</p>");

                    String sqlExcluirVencimentos = "DELETE FROM vencimentos WHERE nr_pedido = ?";
                    psExcluirVencimentos = con.prepareStatement(sqlExcluirVencimentos);
                    psExcluirVencimentos.setInt(1, pedidoIdInt);
                    int vencimentosExcluidos = psExcluirVencimentos.executeUpdate();
                    out.println("<p>Vencimentos excluídos: " + vencimentosExcluidos + "</p>");

                    String sqlExcluirPedido = "DELETE FROM pedido WHERE id = ?";
                    psExcluirPedido = con.prepareStatement(sqlExcluirPedido);
                    psExcluirPedido.setInt(1, pedidoIdInt);
                    int pedidoExcluido = psExcluirPedido.executeUpdate();
                    out.println("<p>Pedido excluído: " + pedidoExcluido + "</p>");

                    con.commit();

                    out.println("<h2 class='success'>Pedido #" + pedidoIdExcluir + " e seus dados relacionados foram excluídos com sucesso.</h2>");
                    out.println("<p><a href='busca_exclusao_pedido.jsp'>Voltar para Busca de Exclusão</a></p>");

                } catch (Exception e) {
                    if (con != null) {
                        try {
                            con.rollback();
                        } catch (SQLException ex) {
                            out.println("<h2 class='error'>Erro ao fazer rollback da transação: " + ex.getMessage() + "</h2>");
                            ex.printStackTrace();
                        }
                    }
                    out.println("<h2 class='error'>Erro ao excluir dados do pedido #" + pedidoIdExcluir + ": " + e.getMessage() + "</h2>");
                    e.printStackTrace();
                } finally {
                    try { if (psExcluirItens != null) psExcluirItens.close(); } catch (SQLException e) {}
                    try { if (psExcluirVencimentos != null) psExcluirVencimentos.close(); } catch (SQLException e) {}
                    try { if (psExcluirPedido != null) psExcluirPedido.close(); } catch (SQLException e) {}
                    try { if (con != null) con.setAutoCommit(true); con.close(); } catch (SQLException e) {}
                }
            } else {
                out.println("<h2 class='error'>ID do pedido para exclusão não fornecido.</h2>");
            }
        %>
    </div>
</body>
</html>