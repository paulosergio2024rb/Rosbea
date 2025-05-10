<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String idStr = request.getParameter("id");
    String pedidoIdStr = request.getParameter("pedido_id");
    String produtoIdStr = request.getParameter("produto_id");
    String quantidadeStr = request.getParameter("quantidade");
    String precoUnitarioStr = request.getParameter("preco_unitario");

    if (idStr != null && !idStr.isEmpty() &&
        pedidoIdStr != null && !pedidoIdStr.isEmpty() &&
        produtoIdStr != null && !produtoIdStr.isEmpty() &&
        quantidadeStr != null && !quantidadeStr.isEmpty() &&
        precoUnitarioStr != null && !precoUnitarioStr.isEmpty()) {

        try {
            int id = Integer.parseInt(idStr);
            int pedidoId = Integer.parseInt(pedidoIdStr);
            int produtoId = Integer.parseInt(produtoIdStr);
            int quantidade = Integer.parseInt(quantidadeStr);
            double preco = Double.parseDouble(precoUnitarioStr);

            Class.forName("org.mariadb.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
            PreparedStatement ps = con.prepareStatement(
                    "UPDATE pedido_item SET pedido_id = ?, produto_id = ?, quantidade = ?, preco = ? WHERE id = ?");
            ps.setInt(1, pedidoId);
            ps.setInt(2, produtoId);
            ps.setInt(3, quantidade);
            ps.setDouble(4, preco);
            ps.setInt(5, id);
            int rowsAffected = ps.executeUpdate();

            ps.close();
            con.close();

            if (rowsAffected > 0) {
                response.sendRedirect("buscar_pedido_item.jsp?success=true"); // Redireciona com mensagem de sucesso
            } else {
                response.sendRedirect("editar_item_form.jsp?item_id=" + id + "&error=update_failed"); // Redireciona com erro de atualização
            }

        } catch (Exception e) {
            response.sendRedirect("editar_item_form.jsp?item_id=" + idStr + "&error=" + e.getMessage()); // Redireciona com mensagem de erro
        }

    } else {
        response.sendRedirect("buscar_pedido_item.jsp?error=missing_data"); // Redireciona com erro de dados faltando
    }
%>