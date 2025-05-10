<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page contentType="text/html;charset=UTF-8"%>

<%
    String pedidoId = request.getParameter("pedido_id");
    String devicePath = "/dev/usb/lp0"; // Caminho padrão - ajuste conforme necessário
%>

<%
    Connection con = null;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");

        // 1. Configuração inicial da impressora
        StringBuilder sb = new StringBuilder();
        sb.append((char) 0x1B).append("@"); // Inicializa impressora
        sb.append((char) 0x1B).append("R").append((char) 0x00); // Define página de código internacional
        sb.append((char) 0x1B).append("t").append((char) 0x10); // Codificação UTF-8

        // 2. Cabeçalho do cupom
        sb.append((char) 0x1B).append("a").append((char) 0x01); // Centralizado
        sb.append((char) 0x1B).append("E").append((char) 0x01); // Negrito
        sb.append("ROS&BEA CALÇADOS\n");
        sb.append((char) 0x1B).append("E").append((char) 0x00); // Desliga negrito
        sb.append("Av. Principal, 123 - Centro\n");
        sb.append("CNPJ: 12.345.678/0001-99\n");
        sb.append("--------------------------------\n");

        // 3. Dados do pedido
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yy HH:mm:ss");
        sb.append("Pedido: #").append(pedidoId).append("\n");
        sb.append("Data: ").append(sdf.format(new java.util.Date())).append("\n");

        // 4. Dados do cliente
        PreparedStatement psPedido = con.prepareStatement(
            "SELECT p.data_pedido, c.nome_do_cliente, c.tel_cel " +
            "FROM pedido p JOIN cadastro_de_clientes c " +
            "ON p.cliente_id = c.rg WHERE p.id = ?");
        psPedido.setInt(1, Integer.parseInt(pedidoId));
        ResultSet pedidoRs = psPedido.executeQuery();

        if (pedidoRs.next()) {
            sb.append("--------------------------------\n");
            sb.append("Cliente: ").append(pedidoRs.getString("nome_do_cliente")).append("\n");
            sb.append("Contato: ").append(pedidoRs.getString("tel_cel")).append("\n");
        }

        // 5. Itens do pedido
        sb.append("--------------------------------\n");
        sb.append((char) 0x1B).append("E").append((char) 0x01); // Negrito
        sb.append(String.format("%-22s %3s %6s %7s\n", "ITEM", "QTD", "VL UN", "TOTAL"));
        sb.append((char) 0x1B).append("E").append((char) 0x00); // Desliga negrito

        double total = 0.0;
        PreparedStatement psItens = con.prepareStatement(
            "SELECT pr.nome, pi.quantidade, pi.preco " +
            "FROM pedido_item pi JOIN produto pr " +
            "ON pi.produto_id = pr.codigo WHERE pi.pedido_id = ?");
        psItens.setInt(1, Integer.parseInt(pedidoId));
        ResultSet itensRs = psItens.executeQuery();

        while (itensRs.next()) {
            String nome = itensRs.getString("nome");
            int qtd = itensRs.getInt("quantidade");
            double preco = itensRs.getDouble("preco");
            double subtotal = qtd * preco;
            total += subtotal;

            // Formatação para 40 colunas
            String linha = String.format("%-22.22s %3d %6.2f %7.2f\n", 
                nome.length() > 22 ? nome.substring(0, 19) + "..." : nome,
                qtd, preco, subtotal);
            sb.append(linha);
        }

        // 6. Totais
        sb.append("--------------------------------\n");
        sb.append((char) 0x1B).append("E").append((char) 0x01); // Negrito
        sb.append(String.format("TOTAL: R$ %28.2f\n", total));
        sb.append((char) 0x1B).append("E").append((char) 0x00); // Desliga negrito

        // 7. Rodapé
        sb.append("--------------------------------\n");
        sb.append((char) 0x1B).append("a").append((char) 0x01); // Centralizado
        sb.append("Obrigado pela preferência!\n");
        sb.append("Volte sempre!\n\n\n");
        
        // 8. Comandos finais
        sb.append((char) 0x1D).append("V").append((char) 66).append((char) 0x00); // Corta papel

        // 9. Envio para impressora
        try {
            java.io.FileOutputStream os = new java.io.FileOutputStream(devicePath);
            os.write(sb.toString().getBytes("UTF-8"));
            os.close();
            
            // Feedback para o usuário
            out.println("<html><head><title>Pedido Impresso</title>");
            out.println("<style>body { font-family: Arial, sans-serif; padding: 20px; }");
            out.println("pre { background: #f5f5f5; padding: 10px; border-radius: 5px; }");
            out.println(".success { color: green; }</style></head>");
            out.println("<body><h2 class='success'>Pedido #" + pedidoId + " impresso com sucesso!</h2>");
            out.println("<p>Conteúdo enviado para impressora:</p>");
            out.println("<pre>" + sb.toString()
                .replace("<", "&lt;").replace(">", "&gt;") + "</pre>");
            out.println("<button onclick='window.history.back()'>Voltar</button>");
            out.println("</body></html>");
            
        } catch (java.io.IOException e) {
            out.println("<html><body><h2>Erro na Impressão</h2>");
            out.println("<p style='color:red'>Erro ao acessar impressora: " + e.getMessage() + "</p>");
            out.println("<p>Verifique:<ul>");
            out.println("<li>Se a impressora está conectada</li>");
            out.println("<li>Se o caminho da impressora está correto: " + devicePath + "</li>");
            out.println("<li>Permissões de acesso ao dispositivo</li></ul></p>");
            out.println("<pre>" + sb.toString()
                .replace("<", "&lt;").replace(">", "&gt;") + "</pre>");
            out.println("<button onclick='window.history.back()'>Voltar</button>");
            out.println("</body></html>");
        }

    } catch (Exception e) {
        out.println("<html><body><h2>Erro no Processamento</h2>");
        out.println("<p style='color:red'>" + e.getMessage() + "</p>");
        out.println("<button onclick='window.history.back()'>Voltar</button>");
        out.println("</body></html>");
        e.printStackTrace();
    } finally {
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
%>