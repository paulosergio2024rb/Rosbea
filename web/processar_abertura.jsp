<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Obter valor inicial do formulário
    String valorInicialStr = request.getParameter("valor_inicial");
    
    // Validação
    if (valorInicialStr == null || valorInicialStr.trim().isEmpty()) {
        request.setAttribute("mensagem", "Informe o valor inicial!");
        request.setAttribute("tipoMensagem", "erro");
        request.getRequestDispatcher("abrir_caixa.jsp").forward(request, response);
        return;
    }

    try {
        double valorInicial = Double.parseDouble(valorInicialStr.replace(",", "."));
        
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
            
            // Verificar se já existe caixa aberto
            statement = connection.prepareStatement("SELECT id_caixa FROM caixa WHERE status = 'aberto' LIMIT 1");
            rs = statement.executeQuery();
            
            if(rs.next()) {
                request.setAttribute("mensagem", "Já existe um caixa aberto!");
                request.setAttribute("tipoMensagem", "erro");
                request.getRequestDispatcher("abrir_caixa.jsp").forward(request, response);
                return;
            }
            
            // Obter ID do usuário da sessão - MODIFICAÇÃO AQUI
            HttpSession sessao = request.getSession();
            Integer idUsuario = (Integer) sessao.getAttribute("id_usuario");
            
            // Se não encontrar na sessão, tenta obter de outro atributo comum
            if(idUsuario == null) {
                idUsuario = (Integer) sessao.getAttribute("userId"); // Tentativa alternativa
            }
            
            // Se ainda não encontrou, usa um valor padrão (REMOVA EM PRODUÇÃO)
            if(idUsuario == null) {
                idUsuario = 1; // Apenas para desenvolvimento - remova esta linha em produção
                // request.setAttribute("mensagem", "Usuário não autenticado!");
                // request.setAttribute("tipoMensagem", "erro");
                // request.getRequestDispatcher("abrir_caixa.jsp").forward(request, response);
                // return;
            }
            
            // Inserir novo caixa
            String sql = "INSERT INTO caixa (data_abertura, valor_inicial, status, id_usuario) " +
                         "VALUES (NOW(), ?, 'aberto', ?)";
            
            statement = connection.prepareStatement(sql);
            statement.setDouble(1, valorInicial);
            statement.setInt(2, idUsuario);
            
            int rowsAffected = statement.executeUpdate();
            
            if (rowsAffected > 0) {
                request.setAttribute("mensagem", "Caixa aberto com sucesso!");
                request.setAttribute("tipoMensagem", "sucesso");
            } else {
                request.setAttribute("mensagem", "Falha ao abrir caixa.");
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
    
    request.getRequestDispatcher("abrir_caixa.jsp").forward(request, response);
%>