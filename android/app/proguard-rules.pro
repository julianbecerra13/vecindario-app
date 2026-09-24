# Flutter and Firebase publish their own consumer rules. Keep model metadata
# used by serialization and enum names used in persisted Firestore documents.
-keepattributes Signature,*Annotation*
-keepclassmembers enum * { public static **[] values(); public static ** valueOf(java.lang.String); }
