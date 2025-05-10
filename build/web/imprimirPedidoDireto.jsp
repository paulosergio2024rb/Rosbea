<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page contentType="text/html;charset=UTF-8"%>

<%
    String pedidoId = request.getParameter("pedido_id");
    if (pedidoId == null || pedidoId.isEmpty()) {
        out.println("<html><body><h2>Erro: ID do pedido não fornecido.</h2></body></html>");
        return;
    }
    String devicePath = "/dev/usb/lp1"; // Caminho do dispositivo da impressora
    DecimalFormat df = new DecimalFormat("#,##0.00");
    DecimalFormat dfInt = new DecimalFormat("#,##0");
    SimpleDateFormat sdfPrint = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    // Obter o mês atual
    Calendar cal = Calendar.getInstance();
    int mesAtual = cal.get(Calendar.MONTH) + 1; // Em Java, os meses começam do 0 (Janeiro = 0)
    
    Connection con = null;
    PreparedStatement psDetalhes = null, psPedidoItens = null, psVencimentos = null, psResumoVendas = null;
    ResultSet rsDetalhes = null, rsPedidoItens = null, rsVencimentos = null, rsResumoVendas = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

        StringBuilder sb = new StringBuilder();
        sb.append((char) 0x1B).append("@"); // Reset de impressora
        sb.append((char) 0x1B).append("t").append((char) 0x10); // UTF-8
        sb.append((char) 0x1B).append("a").append((char) 0x00); // Alinhamento à esquerda

        // Cabeçalho
        sb.append((char) 0x1D).append("!").append((char) 0x11); // Tamanho de fonte
        sb.append("ROSBEA PERFUMES EDP\n");
        sb.append((char) 0x1D).append("!").append((char) 0x00); // Reset do tamanho
        sb.append("===========================================\n");

        String sqlDetalhes = "SELECT * FROM vw_detalhes_impressao_pedido WHERE pedido_id = ?";
        psDetalhes = con.prepareStatement(sqlDetalhes);
        psDetalhes.setInt(1, Integer.parseInt(pedidoId));
        rsDetalhes = psDetalhes.executeQuery();

        String nomeDoCliente = "", clienteRg = "", responsavel = "", direcao = "",
               clienteNr = "", clienteCom = "", clienteBarrio = "", clienteTelefone = "",
               clienteCidade = "", clienteCep = "", dataPedidoFormatada = "", mesAtualRodape = "";

        if (rsDetalhes.next()) {
            nomeDoCliente = rsDetalhes.getString("nome_do_cliente");
            clienteRg = rsDetalhes.getString("cliente_rg");
            responsavel = rsDetalhes.getString("responsavel");
            direcao = rsDetalhes.getString("direcao");
            clienteNr = rsDetalhes.getString("cliente_nr");
            clienteCom = rsDetalhes.getString("cliente_com");
            clienteBarrio = rsDetalhes.getString("cliente_barrio");
            clienteTelefone = rsDetalhes.getString("cliente_telefone");
            clienteCidade = rsDetalhes.getString("cliente_cidade");
            clienteCep = rsDetalhes.getString("cliente_cep");
            mesAtualRodape = rsDetalhes.getString("mes_atual");
            Timestamp tsDataPedido = rsDetalhes.getTimestamp("data_pedido");
            Timestamp tsDataAtende = rsDetalhes.getTimestamp("data_atende"); // <-- adicionada

            if (tsDataPedido != null) {
                dataPedidoFormatada = sdfPrint.format(tsDataPedido);
            }
            String dataAtendeFormatada = "";
            if (tsDataAtende != null) {
                dataAtendeFormatada = sdfPrint.format(tsDataAtende); // <-- formatação
            }

            // Informações do cliente e pedido
            sb.append((char) 0x10).append("!").append((char) 0x02); // Negrito e fontes maiores
            sb.append(nomeDoCliente.toUpperCase()).append("\n");
            sb.append("RG: ").append(clienteRg.toUpperCase()).append("  PEDIDO: #").append(pedidoId).append("\n");
            sb.append("DATA ENTREGA: ").append(dataPedidoFormatada).append("\n");
            sb.append("DATA ATENDIMENTO: ").append(dataAtendeFormatada).append("\n"); // <-- nova linha

            if (responsavel != null && !responsavel.isEmpty()) {
                sb.append("RESPONSÁVEL: ").append(responsavel.toUpperCase()).append("\n");
            }
            sb.append("ENDEREÇO: ").append(direcao.toUpperCase()).append(", ").append(clienteNr.toUpperCase()).append(" ").append(clienteCom.toUpperCase()).append("\n");
            sb.append("BAIRRO: ").append(clienteBarrio.toUpperCase()).append("\n");
            sb.append("CIDADE/CEP: ").append(clienteCidade.toUpperCase()).append(" - ").append(clienteCep.toUpperCase()).append("\n");
            sb.append("TEL.: ").append(clienteTelefone.toUpperCase()).append("\n");
            sb.append("===========================================\n");

            // Itens do pedido
            String sqlItens = "SELECT produto_nome, quantidade, preco_unitario, total_item FROM view_relatorio_pedidos WHERE pedido_id = ? ORDER BY item_id";
            psPedidoItens = con.prepareStatement(sqlItens);
            psPedidoItens.setInt(1, Integer.parseInt(pedidoId));
            rsPedidoItens = psPedidoItens.executeQuery();

            sb.append("ITENS:\n");
            sb.append(String.format("%-30s %4s %9s %9s\n", "PRODUTO", "QTD", "VL.UN", "TOTAL"));
            double totalPedidoGeral = 0.0;
            while (rsPedidoItens.next()) {
                String nome = rsPedidoItens.getString("produto_nome");
                int qtd = rsPedidoItens.getInt("quantidade");
                double unit = rsPedidoItens.getDouble("preco_unitario");
                double total = rsPedidoItens.getDouble("total_item");

                totalPedidoGeral += total;
                sb.append(String.format("%-30.30s %4d %9s %9s\n", nome.toUpperCase(), qtd, df.format(unit), df.format(total)));
            }

            sb.append("===========================================\n");

            // Vencimentos
            String sqlVencimentos = "SELECT data_pedidovcto, prazo FROM vencimentos WHERE nr_pedido = ?";
            psVencimentos = con.prepareStatement(sqlVencimentos);
            psVencimentos.setInt(1, Integer.parseInt(pedidoId));
            rsVencimentos = psVencimentos.executeQuery();
            java.util.List<String> listaVencimentos = new java.util.ArrayList<>();
            while (rsVencimentos.next()) {
                Date dataPedidoVcto = rsVencimentos.getDate("data_pedidovcto");
                int prazo = rsVencimentos.getInt("prazo");

                if (dataPedidoVcto != null) {
                    Calendar calendar = Calendar.getInstance();
                    calendar.setTime(dataPedidoVcto);
                    calendar.add(Calendar.DAY_OF_MONTH, prazo);
                    Date novaDataVcto = calendar.getTime();
                    listaVencimentos.add(sdfPrint.format(novaDataVcto));
                }
            }

            if (!listaVencimentos.isEmpty()) {
                sb.append("VENCIMENTOS:\n");
                double valorParcela = totalPedidoGeral / listaVencimentos.size();
                for (String dataVcto : listaVencimentos) {
                    sb.append("Venc: ").append(dataVcto).append(" - Valor: R$ ").append(df.format(valorParcela)).append("\n");
                }
                sb.append("===========================================\n");
            }

            sb.append(String.format("%37s %10s\n", "TOTAL DO PEDIDO:", "R$ " + df.format(totalPedidoGeral)));
            sb.append("===========================================\n");

            // Resumo das compras do cliente
            sb.append("\nResumo de Compras do Cliente:\n");
            sb.append("===========================================\n");

            // Modificado aqui: filtro para pegar apenas o mês atual
            String sqlResumo = "SELECT mes_atual, rg, total_quantidade FROM vw_relatorio_vendas WHERE rg = ? AND mes_atual = ?";
            psResumoVendas = con.prepareStatement(sqlResumo);
            psResumoVendas.setString(1, clienteRg);
            psResumoVendas.setInt(2, mesAtual); // Filtro para o mês atual
            rsResumoVendas = psResumoVendas.executeQuery();

            while (rsResumoVendas.next()) {
                sb.append("MÊS: ").append(rsResumoVendas.getString("mes_atual")).append("\n");
                sb.append("RG: ").append(rsResumoVendas.getString("rg")).append("\n");
                sb.append("TOTAL COMPRADO: ").append(rsResumoVendas.getInt("total_quantidade")).append(" itens\n");
                sb.append("===========================================\n");
            }

            // Corte de papel
            sb.append("\n\n").append((char) 0x1D).append("V").append((char) 66).append((char) 0x00);

            try {
                java.io.FileOutputStream os = new java.io.FileOutputStream(devicePath);
                os.write(sb.toString().getBytes("UTF-8"));
                os.close();
                out.println("<html><body><h2>Pedido #" + pedidoId + " impresso com sucesso!</h2>");
                out.println("<button onclick=\"window.location.href='relatorios.jsp'\">Voltar para o Pedido</button></body></html>");
            } catch (Exception e) {
                out.println("<html><body><h2>Erro na Impressão</h2><p style='color:red'>" + e.getMessage() + "</p></body></html>");
            }
        }

    } catch (Exception e) {
        out.println("<html><body><h2>Erro no Processamento</h2><p style='color:red'>" + e.getMessage() + "</p></body></html>");
        e.printStackTrace();
    } finally {
        try { if (rsDetalhes != null) rsDetalhes.close(); } catch (Exception e) {}
        try { if (psDetalhes != null) psDetalhes.close(); } catch (Exception e) {}
        try { if (rsPedidoItens != null) rsPedidoItens.close(); } catch (Exception e) {}
        try { if (psPedidoItens != null) psPedidoItens.close(); } catch (Exception e) {}
        try { if (con != null) con.close(); } catch (Exception e) {}
    }
%>
