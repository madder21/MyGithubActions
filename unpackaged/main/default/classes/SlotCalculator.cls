public class SlotCalculator {
    
    public static List<String> findMissingSlots(List<String> busySlots, List<String> availableslots, List<String> calculedFreeSlots) {
        // Liste des créneaux manquants (basée sur la précédente logique)
        List<String> missingSlots = new List<String>();

        for (String slot : availableslots) {
            if (!calculedFreeSlots.contains(slot)) {
                missingSlots.add(slot);
            }
        }

        // Filtrer les créneaux occupés en fonction des busySlots
        List<String> finalMissingSlots = new List<String>();

        // On parcourt chaque créneau manquant
        for (String missingSlot : missingSlots) {
            Boolean isBetweenBusySlots = false;

            // Vérifier si le créneau manquant est exactement un busySlot ou entre deux busySlots
            for (Integer i = 0; i < busySlots.size(); i++) {
                String busySlot = busySlots[i];

                // Si le créneau manquant est égal à un busySlot, on l'élimine
                if (missingSlot == busySlot) {
                    isBetweenBusySlots = true;
                    break;
                }

                // Comparer si le créneau manquant est entre deux busySlots
                if (i < busySlots.size() - 1) {
                    String nextBusySlot = busySlots[i + 1];

                    // Convertir les créneaux horaires en minutes pour la comparaison
                    Integer busySlotStart = getTimeInMinutes(busySlot.split(' - ')[0]);
                    Integer busySlotEnd = getTimeInMinutes(nextBusySlot.split(' - ')[1]);
                    Integer missingSlotStart = getTimeInMinutes(missingSlot.split(' - ')[0]);
                    Integer missingSlotEnd = getTimeInMinutes(missingSlot.split(' - ')[1]);

                    // Vérifier si le créneau manquant se trouve entre deux busySlots
                    if (missingSlotStart >= busySlotStart && missingSlotEnd <= busySlotEnd) {
                        isBetweenBusySlots = true;
                        break;
                    }
                }
            }

            // Ajouter le créneau manquant à la liste finale si ce n'est pas un busySlot ou entre deux busySlots
            if (!isBetweenBusySlots) {
                finalMissingSlots.add(missingSlot);
            }
        }

        return finalMissingSlots;
    }

    // Fonction utilitaire pour convertir un créneau horaire (format HH:MM) en minutes
    public static Integer getTimeInMinutes(String sendingTime) {
        List<String> timeParts = sendingTime.split(':');
        Integer hours = Integer.valueOf(timeParts[0]);
        Integer minutes = Integer.valueOf(timeParts[1]);
        return hours * 60 + minutes;
    }
}