<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DecimalFormat"%>
<%@page contentType="text/html;charset=UTF-8"%>

<%
    String pedidoId = request.getParameter("pedido_id");
    String devicePath = "/dev/usb/lp0"; // Caminho da impressora térmica
    DecimalFormat df = new DecimalFormat("#,##0.00");
%>

<%
    Connection con = null;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");

        // 1. Configuração inicial da impressora
        StringBuilder sb = new StringBuilder();
        sb.append((char) 0x1B).append("@"); // Inicializa impressora
        sb.append((char) 0x1B).append("R").append((char) 0x00); // Define página de código
        sb.append((char) 0x1B).append("t").append((char) 0x10); // Codificação UTF-8

        // 2. Cabeçalho do cupom (centralizado e em negrito)
        sb.append((char) 0x1B).append("a").append((char) 0x01); // Centralizado
        sb.append((char) 0x1B).append("E").append((char) 0x01); // Negrito
        sb.append("ROS&BEA CALÇADOS LTDA\n");
        sb.append((char) 0x1B).append("E").append((char) 0x00); // Desliga negrito
        sb.append("Av. Principal, 123 - Centro\n");
        sb.append("CNPJ: 12.345.678/0001-99\n");
        sb.append("================================\n");

        // 3. Consulta principal usando view_relatorio_pedidos
        PreparedStatement psPedido = con.prepareStatement(
            "SELECT * FROM view_relatorio_pedidos WHERE pedido_id = ? ORDER BY item_id");
        psPedido.setInt(1, Integer.parseInt(pedidoId));
        ResultSet rs = psPedido.executeQuery();

        // Variáveis para armazenar dados do cabeçalho
        String nomeCliente = "";
        String dataPedido = "";
        double totalPedido = 0;
        boolean firstRow = true;

        // 4. Processar resultados
        while (rs.next()) {
            if(firstRow) {
                // Pegar dados do cabeçalho apenas na primeira linha
                nomeCliente = rs.getString("nome_do_cliente");
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                dataPedido = sdf.format(rs.getTimestamp("data_pedido"));
                
                // Dados do pedido
                sb.append((char) 0x1B).append("E").append((char) 0x01); // Negrito
                sb.append("PEDIDO: #").append(pedidoId).append("\n");
                sb.append((char) 0x1B).append("E").append((char) 0x00); // Desliga negrito
                sb.append("Data: ").append(dataPedido).append("\n");
                sb.append("================================\n");
                
                // Dados do cliente
                sb.append("CLIENTE:\n");
                sb.append(nomeCliente).append("\n");
                sb.append("RG: ").append(rs.getString("cliente_rg")).append("\n");
                sb.append("================================\n");
                
                // Cabeçalho dos itens
                sb.append((char) 0x1B).append("E").append((char) 0x01); // Negrito
                sb.append(String.format("%-18s %4s %6s %8s\n", "PRODUTO", "QTD", "VL UN", "TOTAL"));
                sb.append((char) 0x1B).append("E").append((char) 0x00); // Desliga negrito
                
                firstRow = false;
            }
            
            // Processar cada item do pedido
            String nomeProduto = rs.getString("produto_nome");
            String marca = rs.getString("produto_marca");
            int qtd = rs.getInt("quantidade");
            double preco = rs.getDouble("preco_unitario");
            double totalItem = rs.getDouble("total_item");
            String genero = rs.getString("genero");
            double ml = rs.getDouble("ml");
            
            totalPedido += totalItem;
            
            // Formatar linha do produto
            String linhaProduto = String.format("%-18.18s %4d %6s %8s\n",
                (nomeProduto.length() > 18 ? nomeProduto.substring(0, 15) + "..." : nomeProduto),
                qtd,
                df.format(preco),
                df.format(totalItem));
            
            sb.append(linhaProduto);
            
            // Linha adicional com marca/gênero/ML se necessário
            String detalhes = marca;
            if(genero != null && !genero.isEmpty()) {
                detalhes += " " + genero;
            }
            if(ml > 0) {
                detalhes += " ML:" + ml;
            }
            
            if(!detalhes.isEmpty()) {
                sb.append("  ").append(detalhes).append("\n");
            }
            
            // Mostrar diferença entre preço de tabela e preço vendido se houver
            double precoTabela = rs.getDouble("preco_tabela");
            if(precoTabela > 0 && precoTabela != preco) {
                sb.append(String.format("  (Tabela: %s | Economia: %s)\n",
                    df.format(precoTabela),
                    df.format(precoTabela - preco)));
            }
        }

        // 5. Totais
        sb.append("================================\n");
        sb.append((char) 0x1B).append("E").append((char) 0x01); // Negrito
        sb.append(String.format("%24s %8s\n", "TOTAL PEDIDO:", df.format(totalPedido)));
        sb.append((char) 0x1B).append("E").append((char) 0x00); // Desliga negrito
        
        // 6. Rodapé
        sb.append("================================\n");
        sb.append((char) 0x1B).append("a").append((char) 0x01); // Centralizado
        sb.append("Obrigado pela preferência!\n");
        sb.append("Volte sempre!\n\n\n");
        
        // 7. Comando de corte de papel
        sb.append((char) 0x1D).append("V").append((char) 66).append((char) 0x00);

        // 8. Envio para impressora
        try {
            java.io.FileOutputStream os = new java.io.FileOutputStream(devicePath);
            os.write(sb.toString().getBytes("UTF-8"));
            os.close();
            
            // Feedback para o usuário
            out.println("<html><head><title>Pedido Impresso</title>");
            out.println("<style>body { font-family: Arial, sans-serif; padding: 20px; }");
            out.println(".success { color: green; } .debug { background: #f5f5f5; padding: 10px; margin-top: 20px; }</style></head>");
            out.println("<body>");
            out.println("<h2 class='success'>Pedido #" + pedidoId + " impresso com sucesso!</h2>");
            out.println("<button onclick='window.print()'>Imprimir Comprovante</button>");
            out.println("<button onclick='window.history.back()'>Voltar</button>");
            out.println("<div class='debug'><pre>" + sb.toString().replace("<", "&lt;").replace(">", "&gt;") + "</pre></div>");
            out.println("</body></html>");
            
        } catch (java.io.IOException e) {
            out.println("<html><body><h2>Erro na Impressão</h2>");
            out.println("<p style='color:red'>Erro ao acessar impressora: " + e.getMessage() + "</p>");
            out.println("<div class='debug'><pre>" + sb.toString().replace("<", "&lt;").replace(">", "&gt;") + "</pre></div>");
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