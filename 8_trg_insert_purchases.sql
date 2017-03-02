create or replace trigger trg_insert_purchases
  after insert on purchases
  for each row
declare
 v_user varchar2(1000);
begin
  
  select user_id into v_user 
  from tbl_users where login_flag=1; 
  
  insert into logs(log#,who,otime,table_name,operation,key_value)
  values(seq_log#.nextval,v_user,sysdate,'purchases','insert',:new.pur#);
  
  update products
  set qoh=qoh-:new.qty
  where pid=:new.pid;
  
  update customers
  set visits_made=visits_made+1,
  last_visit_date=sysdate  
  where cid=:new.cid;
  

    
  


end trg_insert_purchases;
/
