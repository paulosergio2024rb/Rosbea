<%@page import="java.sql.*"%>
<%
    String usuario = request.getParameter("nome_usuario");
    String senha = request.getParameter("senha");

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

        String sql = "SELECT u.*, n.cargo FROM usuarios u JOIN niveis_acesso n ON u.permissao_acesso = n.nivel WHERE nome_usuario = ? AND senha = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, usuario);
        stmt.setString(2, senha);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            session.setAttribute("usuario", usuario);
            session.setAttribute("nivel", rs.getInt("permissao_acesso"));
            session.setAttribute("cargo", rs.getString("cargo"));

            int nivel = rs.getInt("permissao_acesso");

            // Redireciona com base no nível de acesso
            if (nivel == 1) {
                response.sendRedirect("painel_admin.jsp");
            } else if (nivel == 2) {
                response.sendRedirect("painel_funcionario.jsp");
            } else {
                response.sendRedirect("painel_visualizador.jsp");
            }
        } else {
            response.sendRedirect("login.jsp?erro=1");
        }

        conn.close();
    } catch (Exception e) {
        out.println("Erro: " + e.getMessage());
    }
%>
