<?php

declare(strict_types=1);

namespace App\Commands;

use Illuminate\Contracts\Container\BindingResolutionException;

/**
 * @author      Andreas Knollmann
 * @copyright   2014-2026 Softwareentwicklung Andreas Knollmann
 * @license     http://www.opensource.org/licenses/mit-license.php MIT
 */
class CreateUser extends Base
{
    protected function getCommandName(): string
    {
        return 'create-user';
    }

    protected function getCommandDescription(): string
    {
        return 'Create a new user';
    }

    protected function getCommandParameters(): array
    {
        return [
            $this->prepareDefaultInputOption('rootUser', 'root', 'Name of root user'),
            $this->prepareInputOption('rootPassword', 'Password of root user'),
            $this->prepareInputOption('name', 'Name of user to create'),
            $this->prepareInputOption('password', 'Password of user to create'),
            $this->prepareInputOption('database', 'Name of database to create or grant access to'),
            $this->prepareInputFlag('super', 'Grant superuser privileges'),
            $this->prepareInputFlag('grant', 'Grant all privileges on database with name of database'),
            $this->prepareInputFlag('initial', 'Create initial database with name of database'),
        ];
    }

    /**
     * @throws BindingResolutionException
     */
    protected function executeCommand(): int
    {
        $rootUser = $this->getRequiredOption('rootUser', 'No root user specified!');
        $rootPassword = $this->getRequiredOption('rootPassword', 'No root password specified!');
        $super = $this->getFlag('super');
        $grant = $this->getFlag('grant');
        $initial = $this->getFlag('initial');

        $process = $this->app->make(\App\Models\Process\CreateUser::class);

        $process->execute(
            $this->getOutput(),
            $rootUser,
            $rootPassword,
            $super,
            $grant,
            $initial
        );

        return self::SUCCESS;
    }
}
