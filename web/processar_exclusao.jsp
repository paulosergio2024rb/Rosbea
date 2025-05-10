<%@ page import="java.sql.*" %>
<%
    String rg = request.getParameter("rg");

    if (rg != null && !rg.trim().isEmpty()) {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");

            String sql = "DELETE FROM cadastro_de_clientes WHERE rg = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, rg);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                out.println("<p>Cliente excluído com sucesso.</p>");
            } else {
                out.println("<p>Nenhum cliente encontrado com esse RG.</p>");
            }

            ps.close();
            conn.close();
        } catch (Exception e) {
            out.println("<p>Erro ao excluir: " + e.getMessage() + "</p>");
        }
    } else {
        out.println("<p>RG inválido.</p>");
    }
%>
<a href="excluir_cliente.jsp">Voltar</a>
