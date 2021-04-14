import admin from 'firebase-admin';
import { Service } from 'typedi';

@Service()
export class FirebaseAuthDao {
    fetchRecord(uid: string): Promise<admin.auth.UserRecord> {
        return admin.auth().getUser(uid);
    }
}
