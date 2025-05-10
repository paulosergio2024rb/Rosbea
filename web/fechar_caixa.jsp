<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// 1. Conexão com o banco
String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea";
String dbUser = "paulo";
String dbPassword = "6421";

try (Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword)) {
    
    // 2. Busca o caixa aberto CORRIGIDO (agora incluindo valor_inicial)
    String sqlBuscarCaixa = "SELECT c.id_caixa, c.data_abertura, c.valor_inicial FROM caixa c WHERE c.status = 'aberto' LIMIT 1";
    int idCaixa = -1;
    String dataAbertura = "";
    double valorInicial = 0;
    
    try (PreparedStatement stmt = conn.prepareStatement(sqlBuscarCaixa);
         ResultSet rs = stmt.executeQuery()) {
        if (rs.next()) {
            idCaixa = rs.getInt("id_caixa");
            dataAbertura = rs.getString("data_abertura");
            valorInicial = rs.getDouble("valor_inicial");
        } else {
            out.print("<script>alert('Nenhum caixa aberto encontrado!'); location.href='caixa.jsp';</script>");
            return;
        }
    }

    // 3. Calcula saldo (usando a tabela correta)
    String sqlSaldo = "SELECT " +
                     "SUM(CASE WHEN tipo = 'entrada' THEN valor ELSE 0 END) - " +
                     "SUM(CASE WHEN tipo = 'saida' THEN valor ELSE 0 END) AS saldo " +
                     "FROM movimentacao_caixa WHERE id_caixa = ?";
    
    double saldoFinal = 0;
    try (PreparedStatement stmt = conn.prepareStatement(sqlSaldo)) {
        stmt.setInt(1, idCaixa);
        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                saldoFinal = rs.getDouble("saldo");
            }
        }
    }
    
    // Adiciona o valor inicial ao saldo final
    saldoFinal += valorInicial;

    // 4. Fecha o caixa
    String sqlFechar = "UPDATE caixa SET " +
                      "status = 'fechado', " +
                      "data_fechamento = NOW(), " +
                      "valor_final = ? " +
                      "WHERE id_caixa = ?";
    
    try (PreparedStatement stmt = conn.prepareStatement(sqlFechar)) {
        stmt.setDouble(1, saldoFinal);
        stmt.setInt(2, idCaixa);
        int linhas = stmt.executeUpdate();
        
        if (linhas > 0) {
            out.print("<script>alert('Caixa fechado! Saldo: R$ " + 
                     String.format("%.2f", saldoFinal) + "'); location.href='caixa.jsp';</script>");
        }
    }

} catch (SQLException e) {
    out.print("<script>alert('ERRO: " + e.getMessage().replace("'", "") + "'); history.back();</script>");
}
%>