<%@page import="java.sql.Connection"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Excluir Cliente</title>
</head>
<body>
<%
    String rg = request.getParameter("rg");
    if (rg != null && !rg.trim().isEmpty()) {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            Connection conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

            String sql = "DELETE FROM cadastro_de_clientes WHERE rg = ?";
            PreparedStatement st = conecta.prepareStatement(sql);
            st.setString(1, rg);
            int rows = st.executeUpdate();

            if (rows > 0) {
                out.println("<script>alert('Cliente excluído com sucesso!'); location.href='cadastro_cliente.jsp';</script>");
            } else {
                out.println("<script>alert('Cliente não encontrado.'); location.href='cadastro_cliente.jsp';</script>");
            }

            st.close();
            conecta.close();
        } catch (Exception e) {
            out.println("<script>alert('Erro ao excluir: " + e.getMessage() + "'); location.href='cadastro_cliente.jsp';</script>");
        }
    } else {
        out.println("<script>alert('RG não informado.'); location.href='cadastro_cliente.jsp';</script>");
    }
%>
</body>
</html>
