<%@page import="java.sql.*"%>
<%@page contentType="text/html;charset=UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String clienteRg = request.getParameter("cliente_rg");
    String[] produtoIds = request.getParameterValues("produto_id[]");
    String[] quantidades = request.getParameterValues("quantidade[]");
    String[] subtotais = request.getParameterValues("subtotal[]");

    Connection con = null;
    int pedidoId = -1;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");
        con.setAutoCommit(false);

        PreparedStatement psPedido = con.prepareStatement("INSERT INTO pedido (cliente_id, data_pedido) VALUES (?, CURDATE())", Statement.RETURN_GENERATED_KEYS);
        psPedido.setString(1, clienteRg);
        psPedido.executeUpdate();

        ResultSet generatedKeys = psPedido.getGeneratedKeys();
        if (generatedKeys.next()) {
            pedidoId = generatedKeys.getInt(1);
        }

        PreparedStatement psItem = con.prepareStatement("INSERT INTO pedido_item (pedido_id, produto_id, quantidade, preco) VALUES (?, ?, ?, ?)");
        for (int i = 0; i < produtoIds.length; i++) {
            psItem.setInt(1, pedidoId);
            psItem.setInt(2, Integer.parseInt(produtoIds[i]));
            psItem.setInt(3, Integer.parseInt(quantidades[i]));
            psItem.setDouble(4, Double.parseDouble(subtotais[i]) / Integer.parseInt(quantidades[i]));
            psItem.executeUpdate();
        }

        con.commit();
        response.sendRedirect("relatorio.jsp?pedido_id=" + pedidoId);
    } catch (Exception e) {
        if (con != null) con.rollback();
        out.print("<p style='color:red'>Erro ao salvar pedido: " + e.getMessage() + "</p>");
    } finally {
        if (con != null) con.close();
    }
%>
