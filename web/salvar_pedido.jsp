<%@page import="java.sql.*"%>
<%@page contentType="text/html;charset=UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    // Parâmetros do formulário
    String action = request.getParameter("action");
    String clienteRg = request.getParameter("cliente_rg");
    String[] produtoIds = request.getParameterValues("produto_id[]");
    String[] quantidades = request.getParameterValues("quantidade[]");
    String[] subtotais = request.getParameterValues("subtotal[]");
    String abrirVencimentos = request.getParameter("abrir_vencimentos");
    String mostruario = request.getParameter("mostruario");
    String dataAtende = request.getParameter("data_atende");
    String dataPedidoForm = request.getParameter("data_pedido"); // Novo parâmetro

    // Parâmetros específicos para edição
    String pedidoIdParam = request.getParameter("pedido_id");
    String observacoes = request.getParameter("observacoes");

    Connection con = null;
    int pedidoId = -1;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
        con.setAutoCommit(false);

        if ("editar".equals(action) && pedidoIdParam != null && !pedidoIdParam.isEmpty()) {
            // MODO EDIÇÃO - Atualizar pedido existente
            pedidoId = Integer.parseInt(pedidoIdParam);

            // 1. Atualizar dados principais do pedido
            PreparedStatement psUpdatePedido = con.prepareStatement(
                "UPDATE pedido SET cliente_id = ?, data_pedido = ?, data_atende = ?, observacoes = ?, mostruario = ? WHERE id = ?");
            psUpdatePedido.setString(1, clienteRg);
            psUpdatePedido.setString(2, dataPedidoForm); // Usando o valor do formulário
            psUpdatePedido.setString(3, dataAtende);
            psUpdatePedido.setString(4, observacoes);
            psUpdatePedido.setString(5, mostruario);
            psUpdatePedido.setInt(6, pedidoId);
            psUpdatePedido.executeUpdate();

            // 2. Remover itens existentes
            PreparedStatement psDeleteItens = con.prepareStatement(
                "DELETE FROM pedido_item WHERE pedido_id = ?");
            psDeleteItens.setInt(1, pedidoId);
            psDeleteItens.executeUpdate();

            // 3. Inserir novos itens
            PreparedStatement psInsertItens = con.prepareStatement(
                "INSERT INTO pedido_item (pedido_id, produto_id, quantidade, preco) VALUES (?, ?, ?, ?)");

            for (int i = 0; i < produtoIds.length; i++) {
                psInsertItens.setInt(1, pedidoId);
                psInsertItens.setInt(2, Integer.parseInt(produtoIds[i]));
                psInsertItens.setInt(3, Integer.parseInt(quantidades[i]));
                psInsertItens.setDouble(4, Double.parseDouble(subtotais[i]) / Integer.parseInt(quantidades[i]));
                psInsertItens.executeUpdate();
            }

            // 4. Remover vencimentos existentes (se necessário)
            if (abrirVencimentos != null && abrirVencimentos.equals("true")) {
                PreparedStatement psDeleteVencimentos = con.prepareStatement(
                    "DELETE FROM vencimentos WHERE nr_pedido = ?");
                psDeleteVencimentos.setInt(1, pedidoId);
                psDeleteVencimentos.executeUpdate();
            }

            con.commit();

            // Redirecionamento após edição
            if (abrirVencimentos != null && abrirVencimentos.equals("true")) {
                response.sendRedirect("form_vencimentos.jsp?id_pedido=" + pedidoId + "&data_pedido=" +
                    java.net.URLEncoder.encode(dataPedidoForm, "UTF-8"));
            } else {
                response.sendRedirect("editar_pedido.jsp?id=" + pedidoId + "&success=1");
            }

        } else {
            // MODO CRIAÇÃO - Novo pedido
            PreparedStatement psPedido = con.prepareStatement(
                "INSERT INTO pedido (cliente_id, data_pedido, data_atende, mes_atual, observacoes, mostruario) VALUES (?, ?, ?, MONTH(CURDATE()), ?, ?)",
                Statement.RETURN_GENERATED_KEYS);
            psPedido.setString(1, clienteRg);
            psPedido.setString(2, dataPedidoForm); // Usando o valor do formulário
            psPedido.setString(3, dataAtende);
            psPedido.setString(4, observacoes != null ? observacoes : null); // Permitindo valor nulo
            psPedido.setString(5, mostruario);
            psPedido.executeUpdate();

            ResultSet generatedKeys = psPedido.getGeneratedKeys();
            java.sql.Date dataPedido = null;
            if (generatedKeys.next()) {
                pedidoId = generatedKeys.getInt(1);
                // Recuperar a data do pedido para passar como parâmetro
                PreparedStatement psDataPedido = con.prepareStatement("SELECT data_pedido, data_atende FROM pedido WHERE id = ?");
                psDataPedido.setInt(1, pedidoId);
                ResultSet rsDataPedido = psDataPedido.executeQuery();
                if (rsDataPedido.next()) {
                    dataPedido = rsDataPedido.getDate("data_pedido");
                }
                rsDataPedido.close();
                psDataPedido.close();
            }

            PreparedStatement psItem = con.prepareStatement(
                "INSERT INTO pedido_item (pedido_id, produto_id, quantidade, preco) VALUES (?, ?, ?, ?)");
            for (int i = 0; i < produtoIds.length; i++) {
                psItem.setInt(1, pedidoId);
                psItem.setInt(2, Integer.parseInt(produtoIds[i]));
                psItem.setInt(3, Integer.parseInt(quantidades[i]));
                psItem.setDouble(4, Double.parseDouble(subtotais[i]) / Integer.parseInt(quantidades[i]));
                psItem.executeUpdate();
            }

            con.commit();

            if (abrirVencimentos != null && abrirVencimentos.equals("true") && pedidoId != -1 && dataPedido != null) {
                response.sendRedirect("form_vencimentos.jsp?id_pedido=" + pedidoId + "&data_pedido=" +
                    java.net.URLEncoder.encode(dataPedido.toString(), "UTF-8"));
            } else {
                response.sendRedirect("relatorio.jsp?pedido_id=" + pedidoId);
            }
        }

    } catch (Exception e) {
        if (con != null) con.rollback();
        out.print("<p style='color:red'>Erro ao " + ("editar".equals(action) ? "editar" : "salvar") +
            " pedido: " + e.getMessage() + "</p>");
        e.printStackTrace();

        // Redirecionamento de erro para edição
        if ("editar".equals(action) && pedidoIdParam != null) {
            response.sendRedirect("editar_pedido.jsp?id=" + pedidoIdParam + "&error=1");
        }
    } finally {
        if (con != null) con.close();
    }
%>