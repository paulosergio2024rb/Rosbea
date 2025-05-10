<%@page import="java.sql.*" %>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@page import="java.text.SimpleDateFormat" %>
<%
    Connection con = null;
    PreparedStatement pstmtVencimento = null;
    ResultSet rsRelatorio = null;
    PreparedStatement pstmtRelatorio = null;
    Double totalPedido = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

        String nrPedido = request.getParameter("nr_pedido");
        String dataPedidovcto = request.getParameter("data_pedidovcto");
        String[] prazos = request.getParameterValues("prazo[]");

        int totalParcelas = (prazos != null) ? prazos.length : 1;

        // Buscar a soma total dos itens do pedido
        String sqlRelatorio = "SELECT SUM(total_item) as total_pedido FROM view_relatorio_pedidos WHERE pedido_id = ?";
        pstmtRelatorio = con.prepareStatement(sqlRelatorio);
        pstmtRelatorio.setString(1, nrPedido);
        rsRelatorio = pstmtRelatorio.executeQuery();

        if (rsRelatorio.next()) {
            totalPedido = rsRelatorio.getDouble("total_pedido");
        }

        if (prazos != null && prazos.length > 0 && totalPedido != null) {
            // Inserir com pgto=0 (valor pago inicialmente zero) e data_pagto NULL
            String sqlVencimento = "INSERT INTO vencimentos (nr_pedido, data_pedidovcto, valor_ped, valor_parcela, prazo, quantidade_parcelas, pgto) VALUES (?, ?, ?, ?, ?, ?, 0)";
            pstmtVencimento = con.prepareStatement(sqlVencimento);

            double valorParcela = totalPedido / totalParcelas;

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date dataBase = sdf.parse(dataPedidovcto);
            java.util.Calendar calendar = java.util.Calendar.getInstance();
            calendar.setTime(dataBase);

            for (int i = 0; i < prazos.length; i++) {
                pstmtVencimento.setString(1, nrPedido);

                calendar.setTime(dataBase);
                calendar.add(java.util.Calendar.DAY_OF_MONTH, Integer.parseInt(prazos[i]));
                java.util.Date dataVencimento = calendar.getTime();
                pstmtVencimento.setString(2, sdf.format(dataVencimento));

                pstmtVencimento.setDouble(3, totalPedido);
                pstmtVencimento.setDouble(4, valorParcela);
                pstmtVencimento.setString(5, prazos[i]);
                pstmtVencimento.setInt(6, totalParcelas);
                pstmtVencimento.executeUpdate();
            }
            out.println("<div style='color: green; text-align: center; margin-top: 20px;'>Vencimentos salvos com sucesso!</div>");
            out.println("<script>setTimeout(function(){ window.location.href = 'imprimir_pedido.jsp?pedido_id=" + nrPedido + "'; }, 1500);</script>");
        } else {
            out.println("<div style='color: red; text-align: center; margin-top: 20px;'>Erro ao processar os dados de prazo ou total do pedido.</div>");
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