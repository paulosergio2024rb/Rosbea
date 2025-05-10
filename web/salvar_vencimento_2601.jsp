<%@page import="java.sql.*" %>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Connection con = null;
    PreparedStatement pstmtVencimento = null;
    ResultSet rsRelatorio = null;
    PreparedStatement pstmtRelatorio = null;
    Double totalItemPedido = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

        String nrPedido = request.getParameter("nr_pedido");
        String dataPedidovcto = request.getParameter("data_pedidovcto");
        String[] prazos = request.getParameterValues("prazo[]");

        // Buscar o total_item da view_relatorio_pedidos usando pedido_id
        String sqlRelatorio = "SELECT total_item FROM view_relatorio_pedidos WHERE pedido_id = ?";
        pstmtRelatorio = con.prepareStatement(sqlRelatorio);
        pstmtRelatorio.setString(1, nrPedido);
        rsRelatorio = pstmtRelatorio.executeQuery();

        if (rsRelatorio.next()) {
            totalItemPedido = rsRelatorio.getDouble("total_item");
        }

        if (prazos != null && prazos.length > 0) {
            String sqlVencimento = "INSERT INTO vencimentos (nr_pedido, data_pedidovcto, valor_ped, prazo) VALUES (?, ?, ?, ?)";
            pstmtVencimento = con.prepareStatement(sqlVencimento);

            for (int i = 0; i < prazos.length; i++) {
                pstmtVencimento.setString(1, nrPedido);
                pstmtVencimento.setString(2, dataPedidovcto);
                pstmtVencimento.setDouble(3, totalItemPedido != null ? totalItemPedido : 0.00); // Armazenando total_item em valor_ped
                pstmtVencimento.setString(4, prazos[i]);
                pstmtVencimento.executeUpdate();
            }
            out.println("<div style='color: green; text-align: center; margin-top: 20px;'>Vencimentos salvos com sucesso!</div>");
            out.println("<script>setTimeout(function(){ window.location.href = 'imprimir_pedido.jsp?pedido_id=" + nrPedido + "'; }, 1500);</script>");
        } else {
            out.println("<div style='color: red; text-align: center; margin-top: 20px;'>Erro ao processar os dados de prazo.</div>");
        }

    } catch (Exception e) {
        out.println("<div style='color: red; text-align: center; margin-top: 20px;'>Erro ao salvar os vencimentos: " + e.getMessage() + "</div>");
        e.printStackTrace();
    } finally {
        try { if (rsRelatorio != null) rsRelatorio.close(); } catch (SQLException e) {}
        try { if (pstmtRelatorio != null) pstmtRelatorio.close(); } catch (SQLException e) {}
        try { if (pstmtVencimento != null) pstmtVencimento.close(); } catch (SQLException e) {}
        try { if (con != null) con.close(); } catch (SQLException e) {}
    }
%>