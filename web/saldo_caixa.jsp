<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>

<%
    String dbURL = "jdbc:mariadb://localhost:3306/Rosbea";
    String dbUser = "paulo";
    String dbPassword = "6421";
    Connection conn = null;
    Statement stmt = null;
    ResultSet rsEntrada = null;
    ResultSet rsSaida = null;
    BigDecimal saldo = BigDecimal.ZERO;
    String mensagemErro = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        stmt = conn.createStatement();

        // Calcular total de entradas
        String sqlEntrada = "SELECT SUM(valor) AS total_entrada FROM caixa WHERE tipo = 'entrada'";
        rsEntrada = stmt.executeQuery(sqlEntrada);
        BigDecimal totalEntrada = rsEntrada.next() && rsEntrada.getBigDecimal("total_entrada") != null ? rsEntrada.getBigDecimal("total_entrada") : BigDecimal.ZERO;

        // Calcular total de saídas
        String sqlSaida = "SELECT SUM(valor) AS total_saida FROM caixa WHERE tipo = 'saida'";
        rsSaida = stmt.executeQuery(sqlSaida);
        BigDecimal totalSaida = rsSaida.next() && rsSaida.getBigDecimal("total_saida") != null ? rsSaida.getBigDecimal("total_saida") : BigDecimal.ZERO;

        // Calcular o saldo
        saldo = totalEntrada.subtract(totalSaida);

    } catch (SQLException e) {
        mensagemErro = "Erro ao acessar o banco de dados: " + e.getMessage();
        e.printStackTrace();
    } catch (ClassNotFoundException e) {
        mensagemErro = "Driver do banco de dados não encontrado: " + e.getMessage();
        e.printStackTrace();
    } finally {
        try { if (rsEntrada != null) rsEntrada.close(); } catch (SQLException e) {}
        try { if (rsSaida != null) rsSaida.close(); } catch (SQLException e) {}
        try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Saldo do Caixa</title>
</head>
<body>
    <h1>Saldo do Caixa</h1>
    <% if (mensagemErro != null) { %>
        <p style="color: red;"><%= mensagemErro %></p>
    <% } else { %>
        <p>O saldo atual do caixa é: R$ <%= saldo %></p>
    <% } %>
    <p><a href="pagina_principal.jsp">Voltar</a></p>
</body>
</html>