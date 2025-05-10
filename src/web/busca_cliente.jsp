<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Buscar e Editar Cliente</title>
    <style>
        table {
            border-collapse: collapse;
            width: 100%;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
    </style>
</head>
<body>
    <h2>Buscar Cliente por Nome</h2>
    <form method="get">
        Nome: <input type="text" name="nome" value="<%= request.getParameter("nome") != null ? request.getParameter("nome") : "" %>" />
        <input type="submit" value="Buscar" />
    </form>

<%
    String rg = request.getParameter("rg");
    String nomeBusca = request.getParameter("nome");

    if ((rg != null && !rg.trim().equals("")) || (nomeBusca != null && !nomeBusca.trim().equals(""))) {
        Connection conecta = null;
        PreparedStatement st = null;
        ResultSet rs = null;
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");

            if (rg != null && !rg.trim().equals("")) {
                st = conecta.prepareStatement("SELECT * FROM cadastro_de_clientes WHERE rg = ?");
                st.setString(1, rg);
            } else {
                st = conecta.prepareStatement("SELECT * FROM cadastro_de_clientes WHERE nome_do_cliente LIKE ?");
                st.setString(1, "%" + nomeBusca + "%");
            }

            rs = st.executeQuery();

            // Tabela de resultados da busca
            out.print("<h3>Resultados da Busca</h3>");
            out.print("<table>");
            out.print("<tr>");
            out.print("<th>RG</th>");
            out.print("<th>Nome</th>");
            out.print("<th>Responsável</th>");
            out.print("<th>Tipo</th>");
            out.print("<th>Cidade</th>");
            out.print("<th>Email</th>");
            out.print("<th>Ações</th>");
            out.print("</tr>");

            boolean encontrouRegistros = false;
            
            while (rs.next()) {
                encontrouRegistros = true;
%>
                <tr>
                    <td><%= rs.getString("rg") %></td>
                    <td><%= rs.getString("nome_do_cliente") %></td>
                    <td><%= rs.getString("responsavel") %></td>
                    <td><%= rs.getString("tipo_cliente") %></td>
                    <td><%= rs.getString("cidade") %></td>
                    <td><%= rs.getString("email") %></td>
                    <td>
                        <a href="?rg=<%= rs.getString("rg") %>">Editar</a>
                    </td>
                </tr>
<%
            }
            
            out.print("</table>");

            if (!encontrouRegistros) {
                out.print("<p style='color:red'>Nenhum cliente encontrado</p>");
            }

            // Se foi passado um RG específico, mostra o formulário de edição
            rs.beforeFirst(); // Volta para o início do resultset
            if (rg != null && !rg.trim().equals("") && rs.next()) {
%>
    <h3>Editar Dados do Cliente</h3>
    <form method="post" action="salvar_edicao.jsp">
        <input type="hidden" name="rg" value="<%= rs.getString("rg") %>">
        Nome: <input type="text" name="nome_do_cliente" value="<%= rs.getString("nome_do_cliente") %>"><br>
        Responsável: <input type="text" name="responsavel" value="<%= rs.getString("responsavel") %>"><br>
        Tipo: <input type="text" name="tipo_cliente" value="<%= rs.getString("tipo_cliente") %>"><br>
        Cidade: <input type="text" name="cidade" value="<%= rs.getString("cidade") %>"><br>
        Email: <input type="text" name="email" value="<%= rs.getString("email") %>"><br>
        <input type="submit" value="Salvar Alterações">
    </form>
<%
            }
        } catch (Exception e) {
            out.print("<p style='color:red'>Erro: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) rs.close();
            if (st != null) st.close();
            if (conecta != null) conecta.close();
        }
    }
%>
</body>
</html>