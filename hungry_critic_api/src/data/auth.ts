import admin from 'firebase-admin';
import { Service } from 'typedi';
import { Account, Settings, SignInMethod } from '../models/account';

@Service()
export class FirebaseAuthDao {
    async fetchRecord(uid: string): Promise<admin.auth.UserRecord> {
        return admin.auth().getUser(uid);
    }

    async deleteRecord(settings: Settings): Promise<any> {
        const id = this.fetchProviderId(settings);

        const user = await admin.auth().getUserByProviderUid(id, settings.providerId);
        return admin.auth().deleteUser(user.uid);
    }

    private fetchProviderId(settings: Settings): string {
        switch(settings.method) {
            case SignInMethod.EMAIL:
                return 'email';
            case SignInMethod.FACEBOOK:
                return 'facebook.com';
            case SignInMethod.GOOGLE:
                return 'google.com';
        }
    }
}
