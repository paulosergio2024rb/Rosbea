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
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
        con.setAutoCommit(false);

        // Inserir o pedido na tabela 'pedido'
        PreparedStatement psPedido = con.prepareStatement(
            "INSERT INTO pedido (cliente_id, data_pedido) VALUES (?, CURDATE())",
            Statement.RETURN_GENERATED_KEYS
        );
        psPedido.setString(1, clienteRg);
        psPedido.executeUpdate();

        ResultSet generatedKeys = psPedido.getGeneratedKeys();
        if (generatedKeys.next()) {
            pedidoId = generatedKeys.getInt(1);
        } else {
            throw new SQLException("Falha ao obter o ID do pedido.");
        }

        // Inserir os itens do pedido na tabela 'pedido_item'
        PreparedStatement psItem = con.prepareStatement(
            "INSERT INTO pedido_item (pedido_id, produto_id, quantidade, preco) VALUES (?, ?, ?, ?)"
        );
        for (int i = 0; i < produtoIds.length; i++) {
            int produtoId = Integer.parseInt(produtoIds[i]);
            int quantidade = Integer.parseInt(quantidades[i]);
            double subtotal = Double.parseDouble(subtotais[i]);
            double precoUnitario = subtotal / quantidade;

            psItem.setInt(1, pedidoId);
            psItem.setInt(2, produtoId);
            psItem.setInt(3, quantidade);
            psItem.setDouble(4, precoUnitario);
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
