trigger ShipmentItemTrigger on ShipmentItem (before insert, before update, before delete, after insert, after update, after delete) {

    if(Trigger.isBefore){

        if(Trigger.isUpdate){

        }
        else if(Trigger.isInsert){

        }
        
        else if(Trigger.isDelete){

        }

    }

    else if(Trigger.isAfter){

        if(Trigger.isUpdate){

        }
        else if(Trigger.isInsert){

            ShipmentItemTriggerHandler.handleAfterInsert(Trigger.new);
            
        }
        
        else if(Trigger.isDelete){

        }

    }

}