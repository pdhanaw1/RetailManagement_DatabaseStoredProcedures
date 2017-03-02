create or replace package pkg_retail_management_system is


  -- Created : 11/22/2015 1:46:27 PM
  -- Purpose : Use to access all the objects related to retail management system.As well as perform CRUD operation
  type ref_cursor is ref cursor;
  
  procedure show_products(p_ref_cursor  OUT ref_cursor);
  procedure show_employees(p_ref_cursor   OUT ref_cursor);
  procedure show_customers(p_ref_cursor   OUT ref_cursor);
  procedure show_purchases(p_ref_cursor   OUT ref_cursor);
  procedure show_suppliers(p_ref_cursor   OUT ref_cursor);
  procedure show_supply(p_ref_cursor   OUT ref_cursor);
  procedure show_logs(p_ref_cursor   OUT ref_cursor);
 procedure report_monthly_sale(p_prod_id in varchar2,
                               p_ref_cursor OUT ref_cursor,
                               p_msg  out varchar2);
  procedure check_login_dtls(p_user_id in varchar2,
                             p_pssword in varchar2,
                             p_login_success out number
                             );
  
  procedure update_login(p_user_id varchar2,
                         p_status out number,
                         p_error out varchar2
                                           );

  procedure add_products( p_pname in varchar2,
                          p_qoh in number,
                          p_qoh_threshold in number,
                          p_original_price in number,
                          p_discnt_rate in number,
                          p_status out number,
                          p_error OUT varchar2);

  procedure add_purchases(p_eid in varchar2,
                          p_cid in varchar2,
                          p_pid in varchar2,
                          p_qty in number,
                          p_status out number,
                          p_error out varchar2
                             );
  procedure check_qoh(p_pid varchar2,
                      p_qty number,
                      p_status out number
                      );
  
   procedure check_qoh_threshold(p_pid in varchar2,
                                 p_order out number);
     procedure add_supply(p_pid varchar2,                       
                        p_quantity number,
                        p_status out number,
                        p_error out varchar2
                        );
   
end pkg_retail_management_system;
/
create or replace package body pkg_retail_management_system is

/* =======================================================================

Type: Stored Procedure
Name: show_products
Function: Displays list of all products
=========================================================================*/

  procedure show_products(p_ref_cursor OUT ref_cursor)
  is
  v_sql_str varchar2(4000);
  begin
            v_sql_str:='select pid,pname,qoh,qoh_threshold,original_price,discnt_rate from products';

            open p_ref_cursor for v_sql_str;
  end show_products;
/* =======================================================================

Type: Stored Procedure
Name: show_employees
Function: Displays list of all employees
=========================================================================*/

  procedure show_employees(p_ref_cursor   OUT ref_cursor)
  is
  v_sql_str varchar2(4000);
  begin
            v_sql_str:='select eid,ename,telephone# from employees';

            open p_ref_cursor for v_sql_str;
  end show_employees;
/* =======================================================================

Type: Stored Procedure
Name: show_customers
Function: Displays list of all customers
=========================================================================*/

  procedure show_customers(p_ref_cursor   OUT ref_cursor)
  is
  v_sql_str varchar2(4000);
  begin
            v_sql_str:='select cid,cname,telephone#,visits_made,last_visit_date from customers';

            open p_ref_cursor for v_sql_str;
  end show_customers;
  /* =======================================================================

Type: Stored Procedure
Name: show_purchases
Function: Displays list of all purchases
  =========================================================================*/

  procedure show_purchases(p_ref_cursor   OUT ref_cursor)
  is
  v_sql_str varchar2(4000);
  begin
            v_sql_str:='select pur#,eid,pid,cid,qty,ptime,total_price from purchases';

            open p_ref_cursor for v_sql_str;
  end show_purchases;
/* =======================================================================

Type: Stored Procedure
Name: show_suppliers
Function: Displays list of all suppliers
  =========================================================================*/
  procedure show_suppliers(p_ref_cursor   OUT ref_cursor)
  is
  v_sql_str varchar2(4000);
  begin
            v_sql_str:='select sid,sname,telephone#,city from suppliers';

            open p_ref_cursor for v_sql_str;
  end show_suppliers;
/* =======================================================================

Type: Stored Procedure
Name: show_supply
Function: Displays list of all supply
=========================================================================*/

  procedure show_supply(p_ref_cursor   OUT ref_cursor)
  is
  v_sql_str varchar2(4000);
  begin
            v_sql_str:='select sup#,pid,sid,sdate,quantity from supply';

            open p_ref_cursor for v_sql_str;
  end show_supply;
/* =======================================================================

Type: Stored Procedure
Name: show_logs
Function: Displays list of all logs

=========================================================================*/
  procedure show_logs(p_ref_cursor OUT ref_cursor)
  is
  v_sql_str varchar2(4000);
  begin
            v_sql_str:='select log#,who,otime,table_name,operation,key_value from logs';

            open p_ref_cursor for v_sql_str;
  end show_logs;

/* =======================================================================

Type: Stored Procedure
Name: report_monthly_sale
Function: Displays report of monthly sales of product according to product id i.e pid

=========================================================================*/
procedure report_monthly_sale(p_prod_id in varchar2,
                               p_ref_cursor OUT ref_cursor,
                               p_msg  out varchar2)
  is
  v_sql_str varchar2(4000);
  v_count number(8);
  begin

    select count(1) into v_count
    from products where pid=p_prod_id;

     if(v_count>0) then
      v_sql_str:='select pname,a.* from (
                   select a.pid pid,to_char(ptime,''MON YYYY'') ptime,sum(qty) quantity,round(sum(total_price),4) total_price
                         ,round(sum(total_price)/sum(qty ),4) average_sales_price
                         from purchases a inner join products b on a.pid=b.pid
                         group by to_char(ptime,''MON YYYY''),a.pid
                         order by pid) a inner join products b on a.pid=b.pid
                                                 where a.pid='''||p_prod_id||'''';

      p_msg:='';
      open p_ref_cursor for v_sql_str;
      elsif v_count=0 then
         p_msg:='Product does not exist';
       end if;


  end report_monthly_sale;

/* =======================================================================

Type: Stored Procedure
Name: check_login_dtls
Function: Checks whether login is successful or not

=========================================================================*/

  procedure check_login_dtls(p_user_id in varchar2,
                             p_pssword in varchar2,
                             p_login_success out number
                             )
  is
    v_count number(8);
    v_p_status number(1);
    v_p_error varchar2(1000);
  begin
    select count(1) into v_count
    from tbl_users where user_id=p_user_id and pssword=p_pssword;

    if v_count>0 then
      p_login_success:=1;
      update_login(p_user_id,v_p_status,v_p_error);
    else
      p_login_success:=0;
    end if;
  end check_login_dtls;
  
/* =======================================================================

Type: Stored Procedure
Name: update_login
Function: Updates the login flag for a particular user,login flag is 1 when user is logged in

=========================================================================*/
  
  procedure update_login(p_user_id varchar2,
                         p_status out number,
                         p_error out varchar2
                                           )
  is
  begin 	
      update tbl_users
      set login_flag=1  
      where user_id=p_user_id;  
            
      p_status:=0;
      p_error:='success';
      commit;
      
      
    exception
    when others then
    p_status := 1;
    p_error:=substr(SQLERRM, 1, 200);
      
  end update_login;
  

/* =======================================================================

Type: Stored Procedure
Name: add_products
Function: Adds the products to the product table,when particular product already exist in database
          then it updates its qoh value
=========================================================================*/

  procedure add_products( p_pname in varchar2,
                          p_qoh in number,
                          p_qoh_threshold in number,
                          p_original_price in number,
                          p_discnt_rate in number,
                          p_status out number,
                          p_error OUT varchar2)
    is
      v_pname varchar2(1000);
      v_count number(5); 
      v_error_code number(8);
      v_msg varchar(4000);
                         
    begin
      
      p_error:=' ';
      

      select count(1) into v_count from products where pname=p_pname;
      
      if v_count=0 then                  
        insert into products(pid,pname,qoh,qoh_threshold,original_price,discnt_rate)
               values(seq_pid.nextval,p_pname,p_qoh,p_qoh_threshold,p_original_price,p_discnt_rate);
        p_status:=0;
        p_error:='success';
        commit;
      else 
        select pname into v_pname from products where pname=p_pname;
        
        update products
        set qoh=p_qoh
        where pname=p_pname;
        p_status:=0;
        p_error:='success';
        commit;        
      end if;

    exception
    when others then
    v_msg:=SQLERRM;
    p_error:=ltrim(rtrim(v_msg));
    v_error_code:=SQLCODE;
    p_status:=v_error_code;

    end add_products;
    
/* =======================================================================

Type: Stored Procedure
Name: add_purchases
Function: Adds the purchases made to the purchases table
=========================================================================*/
    
    procedure add_purchases(p_eid in varchar2,
                            p_cid in varchar2,
                            p_pid in varchar2,
                            p_qty in number,
                            p_status out number,
                            p_error out varchar2                            
                               )
    is
     v_original_price number(6,2);
     v_discnt_rate number(3,2);
     v_total_price number(7,2);
     v_count_pid number(6);
     v_count_cid number(6);
     v_count_eid number(6);
     v_msg1 varchar2(1000);
     v_msg2 varchar2(1000);
     v_msg3 varchar2(1000);
     v_msg varchar2(4000);
     v_error_code number(8);
     v_p_order number(8);
    begin
      
      p_error:=' ';
      
      select count(1) into v_count_cid from customers where cid=p_cid;
      select count(1) into v_count_pid from products where pid=p_pid;
      select count(1) into v_count_eid from employees where eid=p_eid;      
      
      
      if (v_count_cid>0 and v_count_pid>0 and v_count_eid>0) then
        
      select original_price ,discnt_rate into v_original_price,v_discnt_rate
      from products where pid=p_pid;
      
      v_total_price:=v_original_price*p_qty*(1-v_discnt_rate);
      
      insert into purchases(pur#,eid,cid,pid,qty,ptime,total_price)
             values(seq_pur#.nextval,p_eid,p_cid,p_pid,p_qty,sysdate,v_total_price);
      
      check_qoh_threshold(p_pid,v_p_order);

      p_status := 0;
      if v_p_order>0 then
        p_status:=1;
      end if;
      p_error:='success';

      commit;
      
      else
        if v_count_cid=0 then
          v_msg1:='Customer id does not exist';
        end if;
        if v_count_pid=0 then
          v_msg2:='Product id does not exist';
         end if;
        if v_count_eid=0 then
          v_msg3:='Employee id does not exist';
        end if;
        v_msg:=v_msg1||v_msg2||v_msg3;
        p_status:=3;
        p_error:=v_msg;
      end if;
      
    exception
    when others then
     v_msg:=SQLERRM;
    p_error:=rtrim(ltrim(v_msg));
    v_error_code:=SQLCODE;
    p_status:=v_error_code;
    end add_purchases;

/* =======================================================================

Type: Stored Procedure
Name: check_qoh
Function: Checks qoh value,if the value of purchase is lower than qoh then it is
          stated to the user by means of p_status,p_status flag equal to 1 indicates
          that qoh is lower than zero 
=========================================================================*/

    procedure check_qoh(p_pid varchar2,
                        p_qty number,
                        p_status out number
                        )
     is
      v_qoh number;
      v_qoh_threshold number; 
     begin
     
       select qoh,qoh_threshold into v_qoh,v_qoh_threshold from products
       where pid=p_pid; 
              
       if v_qoh-p_qty <0 then
         p_status:=1;
       elsif v_qoh-p_qty>=0 then
         p_status:=0;
       end if;
                  
     end check_qoh;

/* =======================================================================

Type: Stored Procedure
Name: check_qoh_threshold
Function: Checks qoh value with qoh_threshold,if the value of qoh is lower than qoh_threshold 
          then particular value needed to maintain the threshold is returned
                     
=========================================================================*/
       
   procedure check_qoh_threshold(p_pid in varchar2,
                                 p_order out number)
     is
        v_qoh number(9);
        v_qoh_threshold number(9);
        v_status number(1);
        v_error varchar2(4000);
     begin
       select qoh,qoh_threshold into v_qoh,v_qoh_threshold 
       from products where pid=p_pid;
           
       if v_qoh_threshold>v_qoh then
         p_order:=v_qoh_threshold-v_qoh;
         add_supply(p_pid,p_order,v_status,v_error);
       else
         p_order:=0;
         end if;
         
   end check_qoh_threshold;

/* =======================================================================

Type: Stored Procedure
Name: add_supply
Function: Adds supply required to be ordered in supply table and also 
          updates quantity in the product table
=========================================================================*/
   
   procedure add_supply(p_pid varchar2,                       
                        p_quantity number,
                        p_status out number,
                        p_error out varchar2
                        )
   is 
     v_msg varchar2(4000); 
     v_sid varchar2(100);
     v_quantity number(8);
     v_qoh number(8);  
     v_count_sid number(8);      
   begin     
     
     select count(1) into v_count_sid from supply 
     where pid=p_pid;
          
     if v_count_sid>0 then
       select min(sid) into v_sid from supply 
       where pid=p_pid
       group by pid;
     end if;      
     
     
     if(v_count_sid=0 ) then                  
        SELECT sid into v_sid
        FROM suppliers
        WHERE ROWNUM= 1;     
     end if;
          
     select qoh into v_qoh  from products where pid=p_pid;
     
     v_quantity:=10+p_quantity;
   
     p_error:=' ';
     insert into supply(sup#,pid,sid,sdate,quantity)
     values(seq_sup#.nextval,p_pid,v_sid,sysdate,v_quantity);
     
     update products
     set qoh=qoh+p_quantity+10
     where pid=p_pid;
     
     p_status:=0;
     p_error:='success';
     commit;
   
    exception
    when others then
    p_status := 1;
    v_msg:=substr(SQLERRM, 1, 200);
    p_error:=ltrim(rtrim(v_msg));
   end add_supply;
   
/* =======================================================================

Type: Stored Procedure
Name: update_login
Function: Updates the login flag for a particular user,login flag is 1 when user is logged in

=========================================================================*/
  
  procedure logout_user(p_user_id varchar2,
                         p_status out number,
                         p_error out varchar2
                                           )
  is
  begin 	
      update tbl_users
      set login_flag=0  
      where user_id=p_user_id;  
            
      p_status:=0;
      p_error:='success';
      commit;      
      
    exception
    when others then
    p_status := 1;
    p_error:=substr(SQLERRM, 1, 200);
      
  end logout_user;

end pkg_retail_management_system;
/
