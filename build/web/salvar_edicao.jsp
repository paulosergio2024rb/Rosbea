<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Salvar Edição</title></head>
<body>
<%
    request.setCharacterEncoding("UTF-8");
    String rg = request.getParameter("rg");
    String nome = request.getParameter("nome_do_cliente");
    String responsavel = request.getParameter("responsavel");
    String tipo = request.getParameter("tipo_cliente");
    String cidade = request.getParameter("cidade");
    String email = request.getParameter("email");

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        Connection conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");
        PreparedStatement st = conecta.prepareStatement(
            "UPDATE cadastro_de_clientes SET nome_do_cliente=?, responsavel=?, tipo_cliente=?, cidade=?, email=? WHERE rg=?"
        );
        st.setString(1, nome);
        st.setString(2, responsavel);
        st.setString(3, tipo);
        st.setString(4, cidade);
        st.setString(5, email);
        st.setString(6, rg);
        int atualizados = st.executeUpdate();
        if (atualizados > 0) {
            out.print("<p style='color:green'>Cliente atualizado com sucesso!</p>");
        } else {
            out.print("<p style='color:red'>Erro ao atualizar cliente.</p>");
        }
        st.close();
        conecta.close();
    } catch (Exception e) {
        out.print("<p style='color:red'>Erro: " + e.getMessage() + "</p>");
    }
%>
<a href="editar_cliente.jsp">Voltar</a>
</body>
</html>
