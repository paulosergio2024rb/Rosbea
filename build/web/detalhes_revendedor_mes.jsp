<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    String rg = request.getParameter("rg");
    String mesAtual = request.getParameter("mes_atual");

    if (rg == null || rg.isEmpty() || mesAtual == null || mesAtual.isEmpty()) {
        out.println("<h2>Parâmetros incompletos.</h2>");
        return;
    }

    DecimalFormat df = new DecimalFormat("#,##0.00");
    SimpleDateFormat sdfExibir = new SimpleDateFormat("dd/MM/yyyy");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

        String sql = "SELECT pedido_id, data_pedido, observacoes, " +
                     "item_id, quantidade, preco_unitario, total_item, produto_codigo, produto_nome " +
                     "FROM view_relatorio_pedidos_revenda " +
                     "WHERE rg = ? AND CAST(SUBSTRING(?, 6, 2) AS UNSIGNED) = mes_atual AND tipo_cliente = 'revendedor' " +
                     "ORDER BY data_pedido, pedido_id, item_id";

        ps = con.prepareStatement(sql);
        ps.setString(1, rg);
        ps.setString(2, mesAtual);
        rs = ps.executeQuery();

        // Obter informações adicionais do revendedor
        String nomeRevendedor = "";
        String cidadeRevendedor = "";
        Statement stmt = con.createStatement();
        ResultSet rsRevendedor = stmt.executeQuery(
                "SELECT nome_do_cliente, cidade FROM view_relatorio_pedidos " +
                "WHERE rg = '" + rg + "' AND tipo_cliente = 'revendedor' LIMIT 1");

        if (rsRevendedor.next()) {
            nomeRevendedor = rsRevendedor.getString("nome_do_cliente");
            cidadeRevendedor = rsRevendedor.getString("cidade");
        }
        rsRevendedor.close();
        stmt.close();

        out.println("<h2>Detalhes de Compras do Revendedor</h2>");
        out.println("<h3>" + nomeRevendedor + " (" + rg + ")</h3>");
        out.println("<p>Cidade: " + cidadeRevendedor + " | Mês: " + mesAtual + "</p>");

        out.println("<table border='1' cellpadding='5' cellspacing='0' style='width:100%; border-collapse: collapse;'>");
        out.println("<thead>");
        out.println("<tr style='background-color: #f2f2f2;'>");
        out.println("<th>Pedido ID</th>");
        out.println("<th>Data</th>");
        out.println("<th>Observações</th>");
        out.println("<th>Item ID</th>");
        out.println("<th>Produto</th>");
        out.println("<th>Qtd</th>");
        out.println("<th>Preço Unit.</th>");
        out.println("<th>Total Item</th>");
        out.println("</tr>");
        out.println("</thead>");
        out.println("<tbody>");

        int currentPedido = -1;
        int totalQuantidade = 0;
        double totalValor = 0.0;
        boolean encontrouResultados = false;

        while (rs.next()) {
            encontrouResultados = true;
            int pedidoId = rs.getInt("pedido_id");
            int quantidade = rs.getInt("quantidade");
            double totalItem = rs.getDouble("total_item");

            totalQuantidade += quantidade;
            totalValor += totalItem;

            if (pedidoId != currentPedido) {
                currentPedido = pedidoId;
                out.println("<tr style='background-color: #e6f3ff;'>");
                out.println("<td>" + pedidoId + "</td>");
                out.println("<td>" + (rs.getDate("data_pedido") != null ? sdfExibir.format(rs.getDate("data_pedido")) : "") + "</td>");
                out.println("<td colspan='6'>" + (rs.getString("observacoes") != null ? rs.getString("observacoes") : "") + "</td>");
                out.println("</tr>");
            }

            out.println("<tr>");
            out.println("<td></td>");
            out.println("<td></td>");
            out.println("<td></td>");
            out.println("<td>" + rs.getInt("item_id") + "</td>");
            out.println("<td>" + rs.getString("produto_nome") + " (" + rs.getString("produto_codigo") + ")</td>");
            out.println("<td style='text-align: right;'>" + quantidade + "</td>");
            out.println("<td style='text-align: right;'>" + df.format(rs.getDouble("preco_unitario")) + "</td>");
            out.println("<td style='text-align: right;'>" + df.format(totalItem) + "</td>");
            out.println("</tr>");
        }

        out.println("</tbody>");
        out.println("</table>");

        if (encontrouResultados) {
            out.println("<div style='margin-top: 15px; font-weight: bold;'>");
            out.println("Total de Itens: " + totalQuantidade + "<br>");
            out.println("Total Geral: " + df.format(totalValor));
            out.println("</div>");
        } else {
            out.println("<p>Nenhum pedido encontrado para este revendedor no mês selecionado.</p>");
        }

        out.println("<div style='margin-top: 20px;'>");
        out.println("<button onclick='window.print()'>Imprimir Relatório</button>");
        out.println("<button onclick='window.close()' style='margin-left: 10px;'>Fechar</button>");
        out.println("</div>");

    } catch (Exception e) {
        out.println("<h2>Erro ao acessar o banco de dados:</h2>");
        out.println("<p>" + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (con != null) con.close(); } catch (Exception e) {}
    }
%>