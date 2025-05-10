<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String rg = request.getParameter("rg");
    String nome = request.getParameter("nome_do_cliente");
    String responsavel = request.getParameter("responsavel");
    String tipo = request.getParameter("tipo_cliente");
    String cidade = request.getParameter("cidade");
    String tel = request.getParameter("tel_fijo");
    String email = request.getParameter("email");

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        Connection conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
        PreparedStatement st = conecta.prepareStatement(
            "UPDATE cadastro_de_clientes SET nome_do_cliente=?, responsavel=?, tipo_cliente=?, cidade=?, tel_fijo=?, email=? WHERE rg=?"
        );
        st.setString(1, nome);
        st.setString(2, responsavel);
        st.setString(3, tipo);
        st.setString(4, cidade);
        st.setString(5, tel);
        st.setString(6, email);
        st.setString(7, rg);

        int atualizou = st.executeUpdate();

        if (atualizou > 0) {
            out.print("<p style='color:green'>Cliente atualizado com sucesso!</p>");
        } else {
            out.print("<p style='color:red'>Erro ao atualizar cliente.</p>");
        }

        st.close();
        conecta.close();
    } catch (Exception e) {
        out.print("Erro: " + e.getMessage());
    }
%>
