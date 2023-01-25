public with sharing class SOM_AdaptReservations {

    public class Request {
     
        @InvocableVariable
        public OrderItemSummary ois;
 
        @InvocableVariable
        public List<SOM_ADV_Reservation> reservations;
 
    }

    @InvocableMethod
    public static List<List<SOM_ADV_Reservation>> AdaptReserv(List<Request> requestList) {
        List<List<SOM_ADV_Reservation>> resList = new List<List<SOM_ADV_Reservation>>();
        List<List<SOM_ADV_Reservation>> resAdapted = new List<List<SOM_ADV_Reservation>>();
        
        for(Request req: requestList){
            List<SOM_ADV_Reservation> resAdap = new List<SOM_ADV_Reservation>();
            for(SOM_ADV_Reservation res : req.reservations){
                System.debug('req.ois  :::: ' +req.ois);
                if(res.stockKeepingUnit == req.ois.stockKeepingUnit && res.locationId == req.ois.reservedAtLocationId ){
                    res.quantityAlreadyAllocated = res.quantityAlreadyAllocated + (Integer)req.ois.quantity;
                }
                resAdap.add(res);
            }
            resAdapted.add(resAdap);
            
        }
        System.debug('resAdapted ::::::: '+resAdapted);
        return resAdapted;
    }
}