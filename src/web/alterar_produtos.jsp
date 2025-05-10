<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.SQLException"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Alteração de Produto</title>
    </head>
    <body>
        <%
            // Variáveis para os parâmetros
            Integer codigo = null, codigo_barbearia = null, barbearia = null, ml = null, 
                    saldo_minimo = null, lista_preco = null, embalagem = null, premio_barber = null;
            String nome = null, marca = null, codigo_fornecedor = null, genero = null, 
                   ativo = null, fornecedor = null;
            Double preco = null, preco_de_custo = null, preco_dolar = null;
            
            try {
                // Conversão dos parâmetros com validação
                String codigoStr = request.getParameter("codigo");
                if (codigoStr != null && !codigoStr.trim().isEmpty()) {
                    codigo = Integer.parseInt(codigoStr);
                }
                
                // Repetir o mesmo padrão para todos os campos numéricos
                String codigoBarbeariaStr = request.getParameter("codigo_barbearia");
                if (codigoBarbeariaStr != null && !codigoBarbeariaStr.trim().isEmpty()) {
                    codigo_barbearia = Integer.parseInt(codigoBarbeariaStr);
                }
                
                // Campos de texto
                nome = request.getParameter("nome");
                marca = request.getParameter("marca");
                // ... outros campos de texto
                
                // Campos decimais
                String precoStr = request.getParameter("preco");
                if (precoStr != null && !precoStr.trim().isEmpty()) {
                    preco = Double.parseDouble(precoStr);
                }
                // ... outros campos decimais
                
                // Validação dos campos obrigatórios
                if (codigo == null) {
                    throw new Exception("Código do produto é obrigatório");
                }
                
                // Conexão com o banco de dados
                Connection conecta = null;
                PreparedStatement st = null;
                
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "root", "6421");
                    
                    // Correção: "codigo_barbearia" no lugar de "codigo_barearia"
                    String sql = "UPDATE produto SET codigo_barbearia = ?, barbearia = ?, ml = ?, " +
                                 "saldo_minimo = ?, lista_preco = ?, embalagem = ?, premio_barber = ?, " +
                                 "nome = ?, marca = ?, codigo_fornecedor = ?, genero = ?, ativo = ?, " +
                                 "fornecedor = ?, preco = ?, preco_de_custo = ?, preco_dolar = ? " +
                                 "WHERE codigo = ?";
                    
                    st = conecta.prepareStatement(sql);
                    
                    // Definir os parâmetros (usando setObject para lidar com possíveis nulls)
                    st.setObject(1, codigo_barbearia);
                    st.setObject(2, barbearia);
                    st.setObject(3, ml);
                    st.setObject(4, saldo_minimo);
                    st.setObject(5, lista_preco);
                    st.setObject(6, embalagem);
                    st.setObject(7, premio_barber);
                    st.setString(8, nome);
                    st.setString(9, marca);
                    st.setString(10, codigo_fornecedor);
                    st.setString(11, genero);
                    st.setString(12, ativo);
                    st.setString(13, fornecedor);
                    st.setObject(14, preco);
                    st.setObject(15, preco_de_custo);
                    st.setObject(16, preco_dolar);
                    st.setInt(17, codigo);
                    
                    int linhasAfetadas = st.executeUpdate();
                    
                    if (linhasAfetadas > 0) {
                        out.print("Os dados do produto " + codigo + " foram alterados com sucesso");
                    } else {
                        out.print("Nenhum produto foi atualizado. Verifique se o código existe.");
                    }
                    
                } catch (ClassNotFoundException e) {
                    out.print("Erro: Driver do banco de dados não encontrado");
                } catch (SQLException e) {
                    out.print("Erro no banco de dados: " + e.getMessage());
                } finally {
                    // Fechar recursos
                    if (st != null) try { st.close(); } catch (SQLException ignore) {}
                    if (conecta != null) try { conecta.close(); } catch (SQLException ignore) {}
                }
                
            } catch (NumberFormatException e) {
                out.print("Erro: Um dos campos numéricos contém valor inválido");
            } catch (Exception e) {
                out.print("Erro: " + e.getMessage());
            }
        %>
    </body>
</html>