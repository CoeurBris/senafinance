import bcrypt from "bcrypt";
import { User } from "../modules/gestiondesutilisateurs/entity/user.entity";
import { myDataSource } from "../configs/data-source";

export class UserService {
  // Obtenir le repository TypeORM pour l'entité User
  private static get userRepository() {
    return myDataSource.getRepository(User);
  }

  // Trouver un utilisateur par e-mail
  static async findByEmail(email: string): Promise<User | null> {
    return await this.userRepository.findOne({
      where: { email },
    });
  }

  // Créer un nouvel utilisateur
  static async createUser(nom: string, email: string, motDePasse: string): Promise<User> {
    const hashedPassword = await bcrypt.hash(motDePasse, 10);
    
    // Création de l'instance en respectant la structure de l'entité User
    const newUser = this.userRepository.create({
      nom: nom,
      email: email,
      motDePasse: hashedPassword,
    } as Partial<User>);

    return await this.userRepository.save(newUser);
  }
}