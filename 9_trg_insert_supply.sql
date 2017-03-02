create or replace trigger trg_insert_supply
  after insert on supply
  for each row
declare
   v_user varchar2(1000);
begin


  select user_id into v_user
  from tbl_users where login_flag=1;

  insert into logs(log#,who,table_name,operation,key_value,otime)
  values(seq_log#.nextval,v_user,'supply','insert',:new.sup#,sysdate);

end trg_insert_supply;
/
