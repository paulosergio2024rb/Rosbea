<%@page import="java.sql.*"%>
<%@page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Lista de Pedidos</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        h2 { margin-bottom: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        a.button {
            padding: 6px 12px;
            background-color: #007BFF;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
        a.button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>

<h2>Relatórios de Pedidos</h2>

<table>
    <tr>
        <th>ID do Pedido</th>
        <th>Cliente</th>
        <th>Data</th>
        <th>Ação</th>
    </tr>

<%
    Connection con = null;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");

        PreparedStatement ps = con.prepareStatement(
            "SELECT p.id, p.data_pedido, c.nome_do_cliente " +
            "FROM pedido p JOIN cadastro_de_clientes c ON p.cliente_id = c.rg " +
            "ORDER BY p.id DESC");

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            int id = rs.getInt("id");
            String cliente = rs.getString("nome_do_cliente");
            Date data = rs.getDate("data_pedido");
%>
    <tr>
        <td><%= id %></td>
        <td><%= cliente %></td>
        <td><%= data %></td>
        <td><a class="button" href="relatorio.jsp?pedido_id=<%= id %>" target="_blank">Visualizar</a></td>
    </tr>
<%
        }
    } catch (Exception e) {
        out.print("<p style='color:red'>Erro ao carregar pedidos: " + e.getMessage() + "</p>");
    } finally {
        if (con != null) con.close();
    }
%>

</table>

</body>
</html>
