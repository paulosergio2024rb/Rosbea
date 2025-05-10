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
    String devicePath = "/dev/usb/lp1";
    DecimalFormat df = new DecimalFormat("#,##0.00");
    DecimalFormat dfInt = new DecimalFormat("#,##0");
    SimpleDateFormat sdfPrint = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    Connection con = null;
    PreparedStatement psDetalhes = null, psPedidoItens = null, psVencimentos = null, psResumoVendas = null;
    ResultSet rsDetalhes = null, rsPedidoItens = null, rsVencimentos = null, rsResumoVendas = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

        StringBuilder sb = new StringBuilder();
        sb.append((char) 0x1B).append("@"); // Reset
        sb.append((char) 0x1B).append("t").append((char) 0x10); // UTF-8
        sb.append((char) 0x1B).append("a").append((char) 0x00); // Alinhamento à esquerda

        // Cabeçalho da empresa
        sb.append((char) 0x1D).append("!").append((char) 0x11);
        sb.append("ROSBEA PERFUMES EDP\n");
        sb.append((char) 0x1D).append("!").append((char) 0x00);
        sb.append("===========================================\n");

        String sqlDetalhes = "SELECT * FROM vw_detalhes_impressao_pedido WHERE pedido_id = ?";
        psDetalhes = con.prepareStatement(sqlDetalhes);
        psDetalhes.setInt(1, Integer.parseInt(pedidoId));
        rsDetalhes = psDetalhes.executeQuery();

        String nomeDoCliente = "", clienteRg = "", responsavel = "", direcao = "",
                clienteNr = "", clienteCom = "", clienteBarrio = "", clienteTelefone = "",
                clienteCidade = "", clienteCep = "", dataPedidoFormatada = "", dataAtendeFormatada = "",
                mesAtualRodape = "", observacoesDoPedido = "";

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
            
            // Formatando as datas
            Timestamp tsDataPedido = rsDetalhes.getTimestamp("data_pedido");
            if (tsDataPedido != null) {
                dataPedidoFormatada = sdfPrint.format(tsDataPedido);
            }
            
            Timestamp tsDataAtende = rsDetalhes.getTimestamp("data_atende");
            if (tsDataAtende != null) {
                dataAtendeFormatada = sdfPrint.format(tsDataAtende);
            }
            
            observacoesDoPedido = rsDetalhes.getString("observacoes");

            // Cabeçalho do pedido com as datas
            sb.append((char) 0x10).append("!").append((char) 0x02);
            sb.append(nomeDoCliente.toUpperCase()).append("\n");
            sb.append("RG: ").append(clienteRg.toUpperCase()).append("  PEDIDO: #").append(pedidoId).append("\n");
            sb.append("DATA ENTREGA: ").append(dataPedidoFormatada).append("\n");
            if (!dataAtendeFormatada.isEmpty()) {
                sb.append("DATA ATENDIMENTO: ").append(dataAtendeFormatada).append("\n");
            }
            if (responsavel != null && !responsavel.isEmpty()) {
                sb.append("RESPONSÁVEL: ").append(responsavel.toUpperCase()).append("\n");
            }
            sb.append("ENDEREÇO: ").append(direcao.toUpperCase()).append(", ").append(clienteNr.toUpperCase()).append(" ").append(clienteCom.toUpperCase()).append("\n");
            sb.append("BAIRRO: ").append(clienteBarrio.toUpperCase()).append("\n");
            sb.append("CIDADE/CEP: ").append(clienteCidade.toUpperCase()).append(" - ").append(clienteCep.toUpperCase()).append("\n");
            sb.append("TEL.: ").append(clienteTelefone.toUpperCase()).append("\n");

            if (observacoesDoPedido != null && !observacoesDoPedido.isEmpty()) {
                sb.append("===========================================\n");
                sb.append("OBSERVAÇÕES:\n");
                sb.append(observacoesDoPedido.toUpperCase()).append("\n");
                sb.append("===========================================\n");
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

            // Itens do pedido
            String sqlItens = "SELECT produto_nome, quantidade, preco_unitario, total_item, produto_codigo, preco_tabela, ml, genero FROM view_relatorio_pedidos WHERE pedido_id = ? ORDER BY item_id";
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
                String codigo = rsPedidoItens.getString("produto_codigo");
                double tabela = rsPedidoItens.getDouble("preco_tabela");
                int ml = rsPedidoItens.getInt("ml");
                String genero = rsPedidoItens.getString("genero");

                totalPedidoGeral += total;
                sb.append(String.format("%-30.30s %4d %9s %9s\n", nome.toUpperCase(), qtd, df.format(unit), df.format(total)));

                String detalhes = "";
                if (codigo != null && !codigo.isEmpty()) detalhes += "Cod: " + codigo;
                if (genero != null && !genero.isEmpty()) detalhes += (detalhes.isEmpty() ? "" : " | ") + genero.substring(0, 1).toUpperCase();
                if (ml > 0) detalhes += (detalhes.isEmpty() ? "" : " | ") + "ML:" + dfInt.format(ml);
                if (!detalhes.isEmpty()) sb.append("  ").append(detalhes).append("\n");

                if (tabela > 0 && tabela != unit) {
                    sb.append(String.format("  (Tab:%s Econ:%s)\n", df.format(tabela), df.format(tabela - unit)));
                }
            }

            sb.append("===========================================\n");

            // Vencimentos
            if (!listaVencimentos.isEmpty()) {
                sb.append("VENCIMENTOS:\n");
                double valorParcela = totalPedidoGeral / listaVencimentos.size();
                for (String dataVcto : listaVencimentos) {
                    sb.append("Venc: ").append(dataVcto).append(" - Valor: R$ ").append(df.format(valorParcela)).append("\n");
                }
                sb.append("===========================================\n");
            }

            // Total do pedido
            sb.append(String.format("%37s %10s\n", "TOTAL DO PEDIDO:", "R$ " + df.format(totalPedidoGeral)));
            sb.append("===========================================\n");

            // Rodapé - Resumo de compras do cliente
            sb.append((char) 0x1B).append("a").append((char) 0x01);
            sb.append("\n\nResumo de Compras do Cliente:\n");
            sb.append("===========================================\n");

            String sqlResumo = "SELECT mes_atual, rg, total_quantidade " +
                             "FROM vw_relatorio_vendas WHERE rg = ? " +
                             "GROUP BY mes_atual, rg " +
                             "ORDER BY mes_atual";
            psResumoVendas = con.prepareStatement(sqlResumo);
            psResumoVendas.setString(1, clienteRg);
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
                out.println("<button onclick=\"window.location.href='http://localhost:8080/Rosbea/pedido.jsp'\">Voltar para Pedidos</button></body></html>");
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
        try { if (rsVencimentos != null) rsVencimentos.close(); } catch (Exception e) {}
        try { if (psVencimentos != null) psVencimentos.close(); } catch (Exception e) {}
        try { if (rsResumoVendas != null) rsResumoVendas.close(); } catch (Exception e) {}
        try { if (psResumoVendas != null) psResumoVendas.close(); } catch (Exception e) {}
        try { if (con != null) con.close(); } catch (Exception e) {}
    }
%>