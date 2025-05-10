<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String idParam = request.getParameter("id");
    String prazoParam = request.getParameter("prazo");
    String pgtoParam = request.getParameter("pgto");

    if (idParam == null || idParam.isEmpty() || prazoParam == null || prazoParam.isEmpty()) {
        response.sendRedirect("exibir_vencimentos.jsp?erro=dados_invalidos");
        return;
    }

    int idVencimento = Integer.parseInt(idParam);
    int novoPrazo = Integer.parseInt(prazoParam);
    String novoPgto = pgtoParam;

    Connection connection = null;
    PreparedStatement preparedStatement = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        connection = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
        String sql = "UPDATE vencimentos SET prazo = ?, pgto = ? WHERE id = ?";
        preparedStatement = connection.prepareStatement(sql);
        preparedStatement.setInt(1, novoPrazo);
        preparedStatement.setString(2, novoPgto);
        preparedStatement.setInt(3, idVencimento);
        int rowsAffected = preparedStatement.executeUpdate();

        if (rowsAffected > 0) {
            response.sendRedirect("exibir_vencimentos.jsp?sucesso=atualizado");
        } else {
            response.sendRedirect("exibir_vencimentos.jsp?erro=falha_atualizacao");
        }

    } catch (Exception e) {
        out.println("Erro ao atualizar vencimento: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("exibir_vencimentos.jsp?erro=erro_banco");
    } finally {
        try { if (preparedStatement != null) preparedStatement.close(); } catch (SQLException e) {}
        try { if (connection != null) connection.close(); } catch (SQLException e) {}
    }
%>