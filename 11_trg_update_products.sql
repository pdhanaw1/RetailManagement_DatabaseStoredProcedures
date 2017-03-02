create or replace trigger trg_update_products
  after update on products  
  for each row
declare
  v_user varchar2(1000);
begin
  
  select user_id into v_user 
  from tbl_users where login_flag=1; 
  
  insert into logs(log#,who,otime,table_name,operation,key_value)
  values(seq_log#.nextval,v_user,sysdate,'products','update',:new.pid);
    

  
end trg_update_products;
/
