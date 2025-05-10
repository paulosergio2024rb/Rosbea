<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Lista de produtos</title>
        <link rel="stylesheet" href="tabela.css"/>
    </head>
    <body>
        <%
            String n;
            n = request.getParameter("nome");
            
            try {
                //fazaer a conexao
                Connection conecta;
                PreparedStatement st;
                Class.forName("org.mariadb.jdbc.Driver");
                conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");
                st = conecta.prepareStatement("SELECT * FROM produto WHERE nome LIKE ? ORDER BY nome ");
                st.setString(1, "%" + n + "%");
                ResultSet rs = st.executeQuery();
                %>
                <table>
                   <tr>
                     <th>Codigo</th><th>Nome</th><th>Marca</th><th>Preço</th>
                   </tr>
                <%
                while (rs.next()) {
                %>
                   <tr>
                       <td><%= rs.getString("codigo")%></td>
                       <td><%= rs.getString("nome")%></td>
                       <td><%= rs.getString("marca")%></td>
                       <td><%= rs.getString("preco")%></td>
                   </tr>
                <%
                }
                %>
                </table>    
                <%
                } catch (Exception x) {
                    out.print("mensagem erro:" + x.getMessage());
                }
        %>
    </body>
</html>