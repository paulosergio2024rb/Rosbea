<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.SQLException"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Cadastro de Produto</title>
        <style>
            .success { color: green; font-size: 16px; }
            .error { color: red; font-size: 16px; }
            .warning { color: orange; font-size: 16px; }
        </style>
    </head>
    <body>
        <%
            // Declaração de variáveis para todos os campos
            Integer codigo = null, codigo_barbearia = null, barbearia = null, ml = null, 
                    saldo_minimo = null, lista_preco = null, embalagem = null, premio_barber = null;
            String nome = null, inspirado = null, codigo_fornecedor = null, genero = null, 
                   ativo = null, fornecedor = null;
            Double preco = null, preco_de_custo = null, preco_dolar = null;
            
            try {
                // Processamento dos campos obrigatórios
                codigo = Integer.parseInt(request.getParameter("codigo"));
                nome = request.getParameter("nome");
                genero = request.getParameter("genero");
                ml = Integer.parseInt(request.getParameter("ml"));
                preco = Double.parseDouble(request.getParameter("preco"));
                
                // Processamento dos campos opcionais (com verificação)
                String codigoBarbeariaStr = request.getParameter("codigo_barbearia");
                if(codigoBarbeariaStr != null && !codigoBarbeariaStr.trim().isEmpty()) {
                    codigo_barbearia = Integer.parseInt(codigoBarbeariaStr);
                }
                
                String barbeariaStr = request.getParameter("barbearia");
                if(barbeariaStr != null && !barbeariaStr.trim().isEmpty()) {
                    barbearia = Integer.parseInt(barbeariaStr);
                }
                
                String saldoMinimoStr = request.getParameter("saldo_minimo");
                if(saldoMinimoStr != null && !saldoMinimoStr.trim().isEmpty()) {
                    saldo_minimo = Integer.parseInt(saldoMinimoStr);
                }
                
                // Outros campos opcionais
                inspirado = request.getParameter("marca");
                codigo_fornecedor = request.getParameter("codigo_fornecedor");
                ativo = request.getParameter("ativo");
                fornecedor = request.getParameter("fornecedor");
                
                String listaPrecoStr = request.getParameter("lista_preco");
                if(listaPrecoStr != null && !listaPrecoStr.trim().isEmpty()) {
                    lista_preco = Integer.parseInt(listaPrecoStr);
                }
                
                String embalagemStr = request.getParameter("embalagem");
                if(embalagemStr != null && !embalagemStr.trim().isEmpty()) {
                    embalagem = Integer.parseInt(embalagemStr);
                }
                
                String premioBarberStr = request.getParameter("premio_barber");
                if(premioBarberStr != null && !premioBarberStr.trim().isEmpty()) {
                    premio_barber = Integer.parseInt(premioBarberStr);
                }
                
                String precoCustoStr = request.getParameter("preco_de_custo");
                if(precoCustoStr != null && !precoCustoStr.trim().isEmpty()) {
                    preco_de_custo = Double.parseDouble(precoCustoStr);
                }
                
                String precoDolarStr = request.getParameter("preco_dolar");
                if(precoDolarStr != null && !precoDolarStr.trim().isEmpty()) {
                    preco_dolar = Double.parseDouble(precoDolarStr);
                }
                
                // Conexão com o banco de dados
                Connection conecta = null;
                PreparedStatement st = null;
                
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
                    
                    // Query SQL com todos os campos
                    String sql = "INSERT INTO produto (codigo, nome, inspirado, preco, codigo_barbearia, " +
                                 "barbearia, ml, saldo_minimo, lista_preco, embalagem, premio_barber, " +
                                 "codigo_fornecedor, genero, ativo, fornecedor, preco_de_custo, preco_dolar) " +
                                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    
                    st = conecta.prepareStatement(sql);
                    
                    // Definir os parâmetros
                    st.setInt(1, codigo);
                    st.setString(2, nome);
                    st.setString(3, inspirado != null ? inspirado : ""); // Trata campo opcional
                    st.setDouble(4, preco);
                    st.setObject(5, codigo_barbearia); // Pode ser null
                    st.setObject(6, barbearia);
                    st.setInt(7, ml);
                    st.setObject(8, saldo_minimo);
                    st.setObject(9, lista_preco);
                    st.setObject(10, embalagem);
                    st.setObject(11, premio_barber);
                    st.setString(12, codigo_fornecedor != null ? codigo_fornecedor : "");
                    st.setString(13, genero);
                    st.setString(14, ativo != null ? ativo : "");
                    st.setString(15, fornecedor != null ? fornecedor : "");
                    st.setObject(16, preco_de_custo);
                    st.setObject(17, preco_dolar);
                    
                    int linhasAfetadas = st.executeUpdate();
                    
                    if(linhasAfetadas > 0) {
                        out.print("<p class='success'>Produto cadastrado com sucesso!</p>");
                        out.print("<p><a href='cadpro.html'>Cadastrar outro produto</a></p>");
                    } else {
                        out.print("<p class='warning'>Nenhum produto foi cadastrado.</p>");
                    }
                    
                } catch (ClassNotFoundException e) {
                    out.print("<p class='error'>Erro: Driver do banco de dados não encontrado.</p>");
                } catch (SQLException e) {
                    if(e.getMessage().contains("Duplicate entry")) {
                        out.print("<p class='error'>Erro: Produto com este código já está cadastrado.</p>");
                    } else if(e.getMessage().contains("Column count doesn't match")) {
                        out.print("<p class='error'>Erro: Número de colunas não corresponde aos valores. Verifique a estrutura da tabela.</p>");
                    } else {
                        out.print("<p class='error'>Erro no banco de dados: " + e.getMessage() + "</p>");
                    }
                } finally {
                    // Fechar recursos
                    if(st != null) try { st.close(); } catch(SQLException ignore) {}
                    if(conecta != null) try { conecta.close(); } catch(SQLException ignore) {}
                }
                
            } catch(NumberFormatException e) {
                out.print("<p class='error'>Erro: Formato numérico inválido em algum campo. Verifique os valores informados.</p>");
            } catch(Exception e) {
                out.print("<p class='error'>Erro: " + e.getMessage() + "</p>");
            }
        %>
    </body>
</html>