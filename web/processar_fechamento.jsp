<%@page import="java.net.URLEncoder"%>
<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Obter parâmetros
    String idCaixaStr = request.getParameter("id_caixa");
    String valorFinalStr = request.getParameter("valor_final");
    String observacoes = request.getParameter("observacoes");

    // Validação
    if(idCaixaStr == null || idCaixaStr.trim().isEmpty() || 
       valorFinalStr == null || valorFinalStr.trim().isEmpty()) {
        response.sendRedirect("fechar_caixa.jsp?erro=Dados+inválidos");
        return;
    }

    try {
        int idCaixa = Integer.parseInt(idCaixaStr);
        double valorFinal = Double.parseDouble(valorFinalStr);
        
        // Configurações de conexão
        String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea";
        String dbUser = "paulo";
        String dbPassword = "6421";
        
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
            
            // Atualizar caixa
            String sql = "UPDATE caixa SET " +
                        "status = 'fechado', " +
                        "data_fechamento = NOW(), " +
                        "valor_final = ? " +
                        "WHERE id_caixa = ?";
            
            stmt = conn.prepareStatement(sql);
            stmt.setDouble(1, valorFinal);
            stmt.setInt(2, idCaixa);
            
            int rowsAffected = stmt.executeUpdate();
            
            if(rowsAffected > 0) {
                response.sendRedirect("caixa.jsp?sucesso=Caixa+fechado+com+sucesso");
            } else {
                response.sendRedirect("fechar_caixa.jsp?erro=Falha+ao+fechar+caixa");
            }
            
        } catch(SQLException e) {
            response.sendRedirect("fechar_caixa.jsp?erro=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
            e.printStackTrace();
        } finally {
            if(stmt != null) stmt.close();
            if(conn != null) conn.close();
        }
        
    } catch(NumberFormatException e) {
        response.sendRedirect("fechar_caixa.jsp?erro=Valores+inválidos");
    } catch(Exception e) {
        response.sendRedirect("fechar_caixa.jsp?erro=Erro+inesperado");
        e.printStackTrace();
    }
%>