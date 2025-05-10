<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Obter parâmetros do formulário
    String descricao = request.getParameter("descricao");
    String valorStr = request.getParameter("valor");
    String formaPagamento = request.getParameter("forma_pagamento");

    // Validação
    if (descricao == null || descricao.trim().isEmpty() || 
        valorStr == null || valorStr.trim().isEmpty() ||
        formaPagamento == null || formaPagamento.trim().isEmpty()) {
        
        request.setAttribute("mensagem", "Preencha todos os campos obrigatórios!");
        request.setAttribute("tipoMensagem", "erro");
        request.getRequestDispatcher("registrar_saida.jsp").forward(request, response);
        return;
    }

    try {
        // Converter valor para double
        double valor = Double.parseDouble(valorStr.replace(",", "."));
        
        // Configurações de conexão
        String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea";
        String dbUser = "paulo";
        String dbPassword = "6421";
        
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet rs = null;
        
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
            
            // 1. Verificar se existe caixa aberto
            int idCaixaAberto = -1;
            statement = connection.prepareStatement("SELECT id_caixa FROM caixa WHERE status = 'aberto' LIMIT 1");
            rs = statement.executeQuery();
            if(rs.next()) {
                idCaixaAberto = rs.getInt(1);
            }
            
            if(idCaixaAberto == -1) {
                request.setAttribute("mensagem", "Não há caixa aberto para registrar movimentações!");
                request.setAttribute("tipoMensagem", "erro");
                request.getRequestDispatcher("registrar_saida.jsp").forward(request, response);
                return;
            }
            
            // 2. Registrar a movimentação de saída
            String sql = "INSERT INTO movimentacao_caixa " +
                        "(id_caixa, descricao, valor, tipo, data_movimentacao, forma_pagamento) " +
                        "VALUES (?, ?, ?, 'saida', NOW(), ?)";
            
            statement = connection.prepareStatement(sql);
            statement.setInt(1, idCaixaAberto);
            statement.setString(2, descricao);
            statement.setDouble(3, valor);
            statement.setString(4, formaPagamento);
            
            int rowsAffected = statement.executeUpdate();
            
            if (rowsAffected > 0) {
                request.setAttribute("mensagem", "Saída registrada com sucesso!");
                request.setAttribute("tipoMensagem", "sucesso");
            } else {
                request.setAttribute("mensagem", "Falha ao registrar saída.");
                request.setAttribute("tipoMensagem", "erro");
            }
            
        } catch (SQLException e) {
            request.setAttribute("mensagem", "Erro no banco de dados: " + e.getMessage());
            request.setAttribute("tipoMensagem", "erro");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (statement != null) try { statement.close(); } catch (SQLException e) {}
            if (connection != null) try { connection.close(); } catch (SQLException e) {}
        }
        
    } catch (NumberFormatException e) {
        request.setAttribute("mensagem", "Valor inválido! Use números decimais (ex: 10,50 ou 10.50)");
        request.setAttribute("tipoMensagem", "erro");
    }
    
    request.getRequestDispatcher("registrar_saida.jsp").forward(request, response);
%>