import { Service } from 'typedi';

@Service()
export class BlockService {
  private blockedIds = <Array<string>>[];

  isBlocked(id: string): boolean {
    return this.blockedIds.some((i) => i === id);
  }
  add(id: string) {
    this.blockedIds.push(id);
  }

  remove(id: string) {
    this.blockedIds = this.blockedIds.filter((i) => i !== id);
  }
}
