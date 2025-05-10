<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
try (Connection conn = DriverManager.getConnection(
    "jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421")) {
    
    // Verifica se já existe caixa aberto
    String sqlVerifica = "SELECT 1 FROM caixa WHERE status = 'aberto' LIMIT 1";
    try (PreparedStatement stmt = conn.prepareStatement(sqlVerifica);
         ResultSet rs = stmt.executeQuery()) {
        if (rs.next()) {
            response.sendRedirect("caixa.jsp?msg=Caixa já está aberto");
            return;
        }
    }

    // Abre novo caixa
    String sqlAbre = "INSERT INTO caixa (data_abertura, valor_inicial, status) VALUES (NOW(), 0, 'aberto')";
    try (PreparedStatement stmt = conn.prepareStatement(sqlAbre)) {
        stmt.executeUpdate();
        response.sendRedirect("caixa.jsp?msg=Caixa aberto com sucesso");
    }
} catch (SQLException e) {
    out.println("<div class='erro'>Erro: " + e.getMessage() + "</div>");
}
%>